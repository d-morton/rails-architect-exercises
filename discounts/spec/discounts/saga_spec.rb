RSpec.describe Discounts::Process do
  before do
    allow(Discounts::Mailer).to receive(:notify_about_discount).and_call_original
  end
  subject(:process) do
    process = Discounts::Process.new
  end

  specify "discount when 3 shipped orders" do
    process.perform(order_shipped(order_number: "111", customer_id: 4499))
    process.perform(order_shipped(order_number: "222", customer_id: 4499))
    process.perform(order_shipped(order_number: "333", customer_id: 4499))
    expect(Discounts::Mailer).to have_received(:notify_about_discount).with(4499).once
  end

  specify "discount when 6 shipped orders" do
    6.times do |time|
      process.perform(order_shipped(order_number: time.to_s, customer_id: 4499))
    end
    expect(Discounts::Mailer).to have_received(:notify_about_discount).with(4499).twice
  end

  specify "no discount when different customers" do
    process.perform(order_shipped(order_number: "111", customer_id: 4499))
    process.perform(order_shipped(order_number: "222", customer_id: 4499))
    process.perform(order_shipped(order_number: "333", customer_id: 5552))
    expect(Discounts::Mailer).not_to have_received(:notify_about_discount)
  end

  specify "message retry is harmless" do
    2.times { process.perform(order_shipped(order_number: "111", customer_id: 4499)) }
    2.times { process.perform(order_shipped(order_number: "222", customer_id: 4499)) }
    2.times { process.perform(order_shipped(order_number: "333", customer_id: 4499)) }
    expect(Discounts::Mailer).to have_received(:notify_about_discount).with(4499).once
  end

  specify "do not count discarded orders" do
    process.perform(order_shipped(order_number: "111", customer_id: 4499))
    process.perform(discard(order_number: "111", customer_id: 4499))
    process.perform(order_shipped(order_number: "222", customer_id: 4499))
    process.perform(order_shipped(order_number: "333", customer_id: 4499))
    expect(Discounts::Mailer).not_to have_received(:notify_about_discount)
  end

  specify "ignore discarded orders which already converted" do
    process.perform(order_shipped(order_number: "111", customer_id: 4499))
    process.perform(order_shipped(order_number: "222", customer_id: 4499))
    process.perform(order_shipped(order_number: "333", customer_id: 4499))

    process.perform(discard(order_number: "111", customer_id: 4499))
    process.perform(discard(order_number: "222", customer_id: 4499))
    process.perform(discard(order_number: "333", customer_id: 4499))

    process.perform(order_shipped(order_number: "44", customer_id: 4499))
    process.perform(order_shipped(order_number: "55", customer_id: 4499))
    process.perform(order_shipped(order_number: "66", customer_id: 4499))

    expect(Discounts::Mailer).to have_received(:notify_about_discount).with(4499).twice
  end

  specify "Enqueues future discards" do
    expect do
      process.perform(order_shipped(order_number: "111", customer_id: 4499))
    end.to have_enqueued_job(Discounts::Process).
      with(discard(order_number: "111", customer_id: 4499))
  end

  private

  def order_shipped(data)
    YAML.dump(Orders::OrderShipped.strict(data: data))
  end

  def discard(data)
    YAML.dump(Discounts::Process::DiscardForDiscounts.new(data.fetch(:order_number), data.fetch(:customer_id)))
  end
end

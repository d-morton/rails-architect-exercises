FakeExpireOrderJob = Class.new(ActiveJob::Base)

module Orders
  RSpec.describe ScheduleExpireOnSubmit do
    specify do
      expect do
        ScheduleExpireOnSubmit.new(::FakeExpireOrderJob).call(
          OrderSubmitted.new(data: {
            order_number:  '12345',
            customer_id:   123,
            items_count:   2,
            net_total:     200.0,
            vat_total:     46.0,
            gross_total:   246.0,
            fee:           0.0 }))
      end.to have_enqueued_job(::FakeExpireOrderJob).with('12345')
    end
  end
end

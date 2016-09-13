class PaymentGateway
  class Transaction < ActiveRecord::Base
    self.table_name = 'payment_gateway_transactions'
  end

  AuthorizationFailed = Class.new(StandardError)
  NotAuthorized       = Class.new(StandardError)

  def authorize(total_amount, card_number)
    card_valid = card_number == '4242424242424242'
    raise AuthorizationFailed unless card_valid
    identifier = SecureRandom.hex(16)
    Transaction.create!(identifier: identifier,
                        amount: total_amount,
                        card_number: card_number,
                        state: 'authorized')
    identifier
  end

  def capture(transaction_identifier)
    trx = Transaction.find_by(identifier: transaction_identifier)
    raise NotAuthorized unless trx
    trx.state = 'captured'
    trx.save!
  end

  def release(transaction_identifier)
    trx = Transaction.find_by(identifier: transaction_identifier)
    raise NotAuthorized unless trx
    trx.state = 'released'
    trx.save!
  end
end

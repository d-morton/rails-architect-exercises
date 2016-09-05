module Payments
  class AuthorizePaymentCommand
    include Command

    attr_accessor :order_number
    attr_accessor :total_amount
    attr_accessor :card_number

    validates_presence_of :order_number, :total_amount, :card_number
  end

  class CapturePaymentCommand
    include Command

    attr_accessor :order_number
    attr_accessor :transaction_identifier

    validates_presence_of :order_number, :transaction_identifier
  end

  class ReleasePaymentCommand
    include Command

    attr_accessor :order_number
    attr_accessor :transaction_identifier

    validates_presence_of :order_number, :transaction_identifier
  end
end

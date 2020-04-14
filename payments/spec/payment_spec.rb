module Payments
  RSpec.describe Payment do
    it 'authorize payment with valid CC number' do
      adapter = double(:adapter)
      expect(adapter).to receive(:authorize).with(123.34, '4242424242424242').and_return('123144567813u4132rt78rgfwbd234567890')
      payment = Payment.new(payment_gateway: adapter)
      expect{ payment.authorize(order_number: '12345',
        total_amount: 123.34,
        card_number:  '4242424242424242') }.not_to raise_error
      expect(payment).to have_applied(
        an_event(PaymentAuthorized).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict
      )
    end

    it 'reject authorization of payment with invalid CC number' do
      adapter = double(:adapter)
      expect(adapter).to receive(:authorize).with(123.34, 'invalid').and_raise(StandardError)
      payment = Payment.new(payment_gateway: adapter)
      expect{ payment.authorize(order_number: '12345',
        total_amount: 123.34,
        card_number:  'invalid') }.not_to raise_error
      expect(payment).to have_applied(
        an_event(PaymentAuthorizationFailed).with_data(
          order_number: '12345'
        ).strict
      )
    end

    it 'fails to capture or release not authorized payment' do
      payment = Payment.new(payment_gateway: nil)
      expect{ payment.capture }.to raise_error(Payment::NotAuthorized)
      expect{ payment.release }.to raise_error(Payment::NotAuthorized)
    end

    it 'authorized payment could be captured' do
      adapter = double(:adapter)
      expect(adapter).to receive(:authorize).with(123.34, '4242424242424242').and_return('123144567813u4132rt78rgfwbd234567890')
      expect(adapter).to receive(:capture).with('123144567813u4132rt78rgfwbd234567890')
      payment = Payment.new(payment_gateway: adapter)
      expect{ payment.authorize(order_number: '12345',
        total_amount: 123.34,
        card_number:  '4242424242424242') }.not_to raise_error
      expect{ payment.capture }.not_to raise_error
      expect(payment).to have_applied(
        an_event(PaymentAuthorized).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict,
        an_event(PaymentCaptured).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict,
      )
    end

    it 'captured payment could still be released' do
      adapter = double(:adapter)
      expect(adapter).to receive(:authorize).with(123.34, '4242424242424242').and_return('123144567813u4132rt78rgfwbd234567890')
      expect(adapter).to receive(:capture).with('123144567813u4132rt78rgfwbd234567890')
      expect(adapter).to receive(:release).with('123144567813u4132rt78rgfwbd234567890')
      payment = Payment.new(payment_gateway: adapter)
      expect{ payment.authorize(order_number: '12345',
        total_amount: 123.34,
        card_number:  '4242424242424242') }.not_to raise_error
      expect{ payment.capture }.not_to raise_error
      expect{ payment.release }.not_to raise_error
      expect(payment).to have_applied(
        an_event(PaymentAuthorized).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict,
        an_event(PaymentCaptured).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict,
        an_event(PaymentReleased).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict
      )
    end

    it 'released payment could not be captured' do
      adapter = double(:adapter)
      expect(adapter).to receive(:authorize).with(123.34, '4242424242424242').and_return('123144567813u4132rt78rgfwbd234567890')
      expect(adapter).to receive(:release).with('123144567813u4132rt78rgfwbd234567890')
      payment = Payment.new(payment_gateway: adapter)
      expect{ payment.authorize(order_number: '12345',
        total_amount: 123.34,
        card_number:  '4242424242424242') }.not_to raise_error
      expect{ payment.release }.not_to raise_error
      expect{ payment.capture }.to raise_error(Payment::InvalidOperation)
      expect(payment).to have_applied(
        an_event(PaymentAuthorized).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict,
        an_event(PaymentReleased).with_data(
          transaction_identifier: '123144567813u4132rt78rgfwbd234567890',
          order_number:           '12345'
        ).strict
      )
    end
  end
end

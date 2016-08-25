module Orders
  class FeeCalculator
    def call(total_value)
      {
        false => 15.0,
        true  => 0.0,
      }.fetch(total_value > 200.0)
    end
  end
end

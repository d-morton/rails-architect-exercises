module Orders
  class NumberGenerator
    def call
      "#{Time.now.year}-#{Time.now.month}-#{SecureRandom.hex(5)}"
    end
  end
end

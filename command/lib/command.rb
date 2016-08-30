require 'active_model'

module Command
  ValidationError = Class.new(StandardError)

  def self.included(base)
    base.include ActiveModel::Model
    base.include ActiveModel::Validations
    base.include ActiveModel::Conversion
  end

  def validate!
    raise ValidationError, errors unless valid?
  end
end

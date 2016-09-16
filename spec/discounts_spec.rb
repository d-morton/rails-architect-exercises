require 'spec_helper'

path = Rails.root.join('discounts/spec')
Dir.glob("#{path}/**/*_spec.rb") do |file|
  require file
end
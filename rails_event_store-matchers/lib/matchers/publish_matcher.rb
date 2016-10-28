require 'rspec/expectations'
require_relative 'utils'

RSpec::Matchers.define :publish do |expected_events|
  match do |aggregate|
    actual_events = aggregate.__send__("unpublished_events")
    expect(map_events(actual_events)).to eq map_events(expected_events)
  end
end

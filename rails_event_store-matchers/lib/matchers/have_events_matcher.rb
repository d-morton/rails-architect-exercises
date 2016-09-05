require 'rspec/expectations'
require_relative 'utils'

RSpec::Matchers.define :have_events do |expected_events|
  match do |actual_events|
    expect(map_events(actual_events)).to eq map_events(expected_events)
  end
end

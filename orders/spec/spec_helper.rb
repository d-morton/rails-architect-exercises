ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.push File.expand_path('../spec', __FILE__)
require_relative '../lib/orders'

require 'rspec/expectations'

RSpec::Matchers.define :publish do |expected_events|

  def map_events(events)
    events.map{|ev| {class: ev.class, data: ev.data.to_h, metadata: ev.metadata.to_h}}
  end

  match do |aggregate|
    actual_events = aggregate.unpublished_events
    expect(map_events(actual_events)).to eq map_events(expected_events)
  end
end

def map_events(events)
  events.map{|ev| {class: ev.class, data: ev.data.to_h }}
end

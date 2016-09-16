RubyEventStore::Event.class_eval do
  def encode_with(coder)
    coder[:event_id] = @event_id
    coder[:metadata] = @metadata.to_h
    coder[:data]     = @data.to_h
  end

  def init_with(coder)
    @event_id = coder[:event_id]
    @metadata = ClosedStruct.new(coder[:metadata])
    @data     = ClosedStruct.new(coder[:data])
  end
end
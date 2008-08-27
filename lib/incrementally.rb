class Incrementally
  
  # Don't process every object in the database -- do it a few at a time
  def self.process( an_active_record_class, at_a_time = 1000)
    objects_count = an_active_record_class.count
    i = 0
    raise "at_a_time must be greater than 0" if at_a_time < 1
    until( i > objects_count)
      objects = an_active_record_class.find( :all, :offset => i, :limit => at_a_time)
      objects.each do |instance|
        if block_given?
          yield instance
        end
      end
      i += at_a_time
    end
  end
end # class
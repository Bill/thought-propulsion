module Alert

  ALERT_CATEGORIES = %w(error warn inform).collect{|c| c.to_sym}
  
  def error( msg, now_later = :later)
    alert( :error, msg, now_later)
  end
  def warn( msg, now_later = :later)
    alert( :warn, msg, now_later)
  end
  def inform( msg, now_later = :later)
    alert( :inform, msg, now_later)
  end

  def alert( category, msg, now_later = :later)
    raise ArgumentError("#{category.to_s} is not a valid alert category") unless ALERT_CATEGORIES.include?(category)
    (now_later == :later ? flash : flash.now)[category] = to_array( flash[category]).concat( to_array( msg))
  end
  
  protected
  
  def to_array(obj)
    case obj
      when nil then []
      when Array then obj
      else [obj]
    end
  end
  
end
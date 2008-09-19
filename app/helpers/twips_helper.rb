module TwipsHelper
  def datetime( time)
    "#{date(time)} | #{time(time)}"
  end
  
  def date( time)
    time.strftime( '%b %d %Y')
  end
  
  def time( time)
    time.strftime( '%I:%M %p %Z')
  end
end
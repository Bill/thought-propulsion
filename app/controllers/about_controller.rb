class AboutController < ThoughtPropulsionApplicationController
  
  def index
  end
  
  protected
  def page_title
    super + ' | Why We Do It'
  end
  
end
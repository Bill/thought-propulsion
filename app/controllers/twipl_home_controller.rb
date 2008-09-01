class TwiplHomeController < TwiplApplicationController
  
  layout 'twipl_home'
  
  def index
  end
  
  protected
  
  def page_title
    super + ' | Authoring Built About You'
  end
  
end
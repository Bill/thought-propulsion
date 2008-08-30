class TwiplHomeController < ApplicationController
  
  layout 'twipl_home'
  
  def index
  end
  
  protected
  
  def page_title
    @page_title = "Authoring Built About You"
  end
  
end
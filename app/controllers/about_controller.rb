class AboutController < ApplicationController
  
  layout 'home'
  
  def index
  end
  
  protected
  def page_title
    @page_title = "Why We Do It"
  end
  
end
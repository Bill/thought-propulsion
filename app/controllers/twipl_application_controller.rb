# This is thoughtpropulsion.com's base controller
class TwiplApplicationController < ApplicationController
  
  layout 'twipl_home'
  
  protected
  
  def page_title
    'Twipl'
  end
end

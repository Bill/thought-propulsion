# This is thoughtpropulsion.com's base controller
class ThoughtPropulsionApplicationController < ApplicationController
  
  layout 'home'
  
  protected
  
  def page_title
    'Thought Propulsion'
  end
end

# The purpose of this controller is to allow us to dynamically generate our stylesheets. This lets us
# use the full power of Ruby to e.g. define color values one time and reuse them (via variables), to
# define basic dimensions and then compute derived dimensions from those.
class ApplicationStylesheetController < ApplicationController
  
  def show
    respond_to do |wants|
      wants.css {}
    end    
  end
end
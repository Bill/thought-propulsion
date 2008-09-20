class DaysController < ApplicationController
  
  # layout proc{ |controller| controller.params[:layout]}
  layout proc{ | controller | controller.layout }
  
  def index
    publisher = User.for_host( request.host).find(:first)
    (render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404) and return) unless publisher
    @days = Day.all( publisher, authenticated_identity_url)
  end
  def show
  end
end
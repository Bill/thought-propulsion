class OpenidController < ApplicationController

  def new
    # TODO: show a form requesting the user's OpenID
  end

  def create
    # TODO: begin the OpenID verification process
  end

  def complete
    # TODO: complete the OpenID verification process
  end
  
  protected

    def openid_consumer
      @openid_consumer ||= OpenID::Consumer.new(session,      
        OpenID::ActiveRecordStore.new())
    end
end
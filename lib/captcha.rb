class Captcha
  require 'open-uri'

  include Validateable
  
  validates_each :captcha do |model,attr,value|     
    # if CAPTCHA is correct then note that in the session so we don't re-display CAPTCHA
    # also only test the captcha once since retesting it will always fail
    model.captcha_verified = ( model.captcha_verified || (ENV['RAILS_ENV'] == 'test' ? value == 'CAPTCHA' : (open("http://captchator.com/captcha/check_answer/#{model.captcha_session}/#{value}").read.to_i.nonzero? rescue nil)) )
    model.errors.add( :captcha, "characters you entered didn't match those shown in the picture you tricky android. I&apos;ll give you another try.") unless model.captcha_verified
  end
  
  attr_accessor :captcha
  attr_accessor :captcha_session
  attr_accessor :captcha_verified
  
  def initialize( h = {})
    %w( captcha captcha_session captcha_verified).each do |name|
      send "#{name}=".to_sym, h[name.to_sym] if h.has_key?(name.to_sym)
    end
    self.captcha_session ||= Propel::Nonce.generate
  end
  
  def attributes
    %w( captcha captcha_session captcha_verified).inject({}){|memo,name| memo[name] = send("#{name}".to_sym); memo }
  end
end
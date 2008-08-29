require File.dirname(__FILE__) + '/../spec_helper'

describe DomainName, 'domain name validator' do
  
  VALID_LABEL_CHARS = '_-' + ('0'..'9').collect.join + ('a'..'z').collect.join
  VALID_DOMAIN_CHARS = VALID_LABEL_CHARS + '.'
  INVALID_DOMAIN_CHARS = '~!@#$%^&*()+`={}|[]\:;"\'<>,?/' + ('A'..'Z').collect.join
  INVALID_LABEL_CHARS = INVALID_DOMAIN_CHARS + '.'
  
  describe 'should reject invalid domains like' do
    after(:each) do
      DomainName.valid_domain?( @domain).should == false
    end
    it 'a nil one' do
      @domain = nil
    end
    it 'an empty one' do
      @domain = ''
    end
    it 'one with 256 labels' do
      @domain = (0..255).collect{'x'}.join('.')
    end
    it 'one with a ! in it' do
      @domain = '!'
    end
  end
  
  describe 'should accept valid domains like' do
    after(:each) do
      DomainName.valid_domain?( @domain).should == true
    end
    it 'one with 1 label' do
      @domain = 'com'
    end
    it 'one with 255 labels' do
      @domain = (0..254).collect{'x'}.join('.')
    end
  end
  
  describe 'should reject invalid labels like' do
    after(:each) do
      DomainName.valid_label?( @label).should == false
    end
    it 'a nil one' do
      @label = nil
    end
    it 'an empty one' do
      @label = ''
    end
    it 'one with 64 characters' do
      @label = valid_label_chars(64)
    end
    it 'one with an uppercase character' do
      @label = 'D'
    end
    it 'one with a double-quote (")' do
      @label = 'x"x'
    end
  end

  describe 'should accept valid labels like' do
    after(:each) do
      DomainName.valid_label?( @label).should == true
    end
    it 'one with 1 character' do
      @label = 'p'
    end
    it 'one with 63 characters' do
      @label = valid_label_chars(63)
    end
    it 'one with an underscore (_)' do
      @label = 'dd_dd'
    end
    it 'one with a hyphen (-)' do
      @label = '-xyz'
    end
    it 'one with a digit (7)' do
      @label = '7x'
    end
    it 'one with a digit, a hyphen and an underscore' do
      @label = '8-_'
    end
    it 'one with a digit, a hyphen and an underscore and an alphabetic character' do
      @label = '7_-r'
    end
  end
  
  def valid_label_chars(howmany)
    chars( howmany, VALID_LABEL_CHARS)
  end
  
  def invalid_label_chars(howmany)
    chars( howmany, INVALID_LABEL_CHARS)
  end

  def valid_domain_chars(howmany)
    chars( howmany, VALID_DOMAIN_CHARS)
  end
  
  def invalid_domain_chars(howmany)
    chars( howmany, INVALID_DOMAIN_CHARS)
  end
  
  def chars( howmany, choices)
    (1..howmany).collect{ choices[rand choices.length].chr}.join
  end
end
require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end
  describe 'should reject invalid users' do
    after(:each) do
      @user.valid?.should == false
    end
    it 'like ones with an uppercase nickname' do
      @user.nickname = 'Bill'
    end
    it 'like ones with a nickname with spaces' do
      @user.nickname = 'bill burcham'
    end
  end
  describe 'should accept valid users' do
    after(:each) do
      @user.valid?.should == true
    end
    it 'like ones with a valid nickname' do
      @user.nickname = 'bill_burcham'
      @user.identity_url = 'foo.bar.baz'
    end

    describe 'and normalize valid identity URL' do
      before(:each) do
        @user.nickname = 'valid'
      end
      after(:each) do
        @user.valid?.should == true
      end
      it 'when URL has http scheme' do
        @user.identity_url = 'http://foo.bar.com'
        @user.normalized_identity_url.should == 'http://foo.bar.com'
      end
      it 'when URL has no scheme, no query parameters and no path' do
        @user.identity_url = 'foo.bar.com'
        @user.normalized_identity_url.should == 'http://foo.bar.com'
      end
      it 'when URL has https scheme' do
        @user.identity_url = 'https://foo.bar.com'
        @user.normalized_identity_url.should == 'https://foo.bar.com'
      end
      it 'when URL has query parameters' do
        @user.identity_url = 'foo.bar.com?foo=x&bar=y'
        @user.normalized_identity_url.should == 'http://foo.bar.com?foo=x&bar=y'
      end
      it 'when URL has path and query parameters' do
        @user.identity_url = 'foo.bar.com/x/y/z?foo=x&bar=y'
        @user.normalized_identity_url.should == 'http://foo.bar.com/x/y/z?foo=x&bar=y'
      end
    end

  end
  
end
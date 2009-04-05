require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ApplicationHelper)
  end
  
  describe 'url_for_silent_port' do
    it 'should elide nil ports' do
      helper.url_for_silent_port( :controller => 'home', :action => 'index', :host => "thoughtpropulsion.com", :port => nil).should == 'http://thoughtpropulsion.com/'
    end
  end
  
  describe 'hard coded url formatters' do
    it 'should generate thoughtpropulsion_url' do
      helper.thoughtpropulsion_url.should == 'http://www.thoughtpropulsion.com/'
    end
    it 'should generate thoughtpropulsion_blog_url' do
      helper.thoughtpropulsion_blog_url.should == 'http://blog.thoughtpropulsion.com/'
    end
    it 'should generate thoughtpropulsion_contact_url' do
      helper.thoughtpropulsion_contact_url.should == 'http://www.thoughtpropulsion.com/contact'
    end
    it 'should generate thoughtpropulsion_why_url' do
      helper.thoughtpropulsion_why_url.should == 'http://www.thoughtpropulsion.com/why'
    end
  end
end


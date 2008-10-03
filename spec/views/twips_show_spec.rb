require File.dirname(__FILE__) + '/../spec_helper'

describe 'twips views' do
  
  fixtures :users

  shared_examples_for 'sanitize' do
    it 'should elide script tags' do
      response.should_not have_tag('script')
    end
  end

  shared_examples_for 'allow HTML' do
    it 'should allow HTML tags' do
      response.should have_tag('p') do |p|
        # TODO: replace with with_text call once rspec supports with_text
        include_text 'hellow world'
      end
    end
  end
  
  before(:each) do
    body = "<script src='foo.bar.com/baz' type='text/javascript'></script><p>hellow world</p>"
    title = "<script src='foo.bar.com/baz' type='text/javascript'></script>important!"
    @twip = Twip.new( :title => title, :public => true, :body => body, :created_at => Time.now, :updated_at => Time.now)
    @twip.author = users(:fred)
  end


  describe '/twips/_show' do
    before(:each) do
      render :partial => '/twips/show', :locals => { :show => @twip}
    end

    it_should_behave_like 'sanitize'
    it_should_behave_like 'allow HTML'
  end

  describe '/twips/_show_summary' do
    before(:each) do
      render :partial => '/twips/show_summary', :locals => { :show_summary => @twip}
    end

    it_should_behave_like 'sanitize'
    it_should_behave_like 'allow HTML'
  end
  
end
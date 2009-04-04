require File.dirname(__FILE__) + '/../spec_helper'

describe 'builder' do

  shared_examples_for 'always' do
    it 'shows button group' do
      response.should have_tag('div[class*=buttons]')
    end
    
    it 'shows undo link' do
      with_tag('div[class*=buttons]') do
        with_tag('a') do
          with_tag('img[src=/images/icons/arrow_undo.png]')
        end
      end
    end
  end
  
  shared_examples_for 'controls mode' do
    it 'renders form and controls' do
      response.should have_tag('form') do
        with_tag( 'input[id=article_title][type=text]')
        with_tag( 'button[type=submit][class*=positive]')
      end
    end
  end

  shared_examples_for 'no scaffold' do
    it 'renders no block tag around attribute content' do
      response.should_not have_tag('p > input')
      response.should_not have_tag('div > input')
    end
  end
  
  shared_examples_for 'controls mode without scaffold' do
    it_should_behave_like 'no scaffold'
    it 'renders no tag around object content' do
      response.should_not have_tag('* > form')
    end
  end

  shared_examples_for 'no controls mode without scaffold' do
    it_should_behave_like 'no scaffold'
    it 'renders no tag around object content' do
      response.should_not have_tag('* > input')
    end
  end

  shared_examples_for 'no controls mode' do
    it 'renders no form and no controls' do
      response.should_not have_tag('form')
      response.should_not have_tag( 'input[id=article_title][type=text]')
      response.should_not have_tag( 'button[type=submit][class*=positive]')
    end
  end

  shared_examples_for 'error message' do
    it 'displays error message' do
      response.should have_tag( 'label[for=article_title]', "Title: (required) Can't be blank.")
    end
  end

  shared_examples_for 'error class' do
    it 'has error class on container' do
      response.should have_tag('p[class*=error]')
    end
  end

  shared_examples_for 'no error class' do
    it 'has no error class on container' do
      response.should_not have_tag('p[class*=error]')
    end
  end

  shared_examples_for 'no error message' do
    it 'displays no error message' do
      response.should_not have_tag( 'label[for=article_title]', "Title: (required) Can't be blank.")
    end
  end
  
  shared_examples_for 'no error' do
    it_should_behave_like 'no error class'
    it_should_behave_like 'no error message'
  end
  
  
  shared_examples_for 'error scaffold' do
    it_should_behave_like 'error message'
    it_should_behave_like 'error class'
  end
  
  def article
    @article ||= Article.new( :title => 'first', :body => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', :published => true)
  end

  before(:each) do
    assigns[:article] = article
    article.valid?
  end

  describe 'in controls mode (default)' do

    before(:each) do
      render :partial => 'article/show_default'
    end

    it_should_behave_like 'always'
    
    describe 'rendering an object with no errors' do
      it_should_behave_like 'controls mode'
    end
  
    describe 'rendering an object with errors' do
      def article
        super.title = nil # make the article invalid
        super
      end
      it_should_behave_like 'controls mode'
      it_should_behave_like 'error scaffold'
    end
  end # 'in controls mode (default)'
  
  describe 'in no_controls mode' do
    
    before(:each) do
      render :partial => 'article/show_no_controls'
    end

    it_should_behave_like 'always'
    
    describe 'rendering an object with no errors' do
      it_should_behave_like 'no controls mode'
    end
  
    describe 'rendering an object with errors' do
      def article
        super.title = nil # make the article invalid
        super
      end
      it_should_behave_like 'no error'
    end
  end
  
  describe 'with no scaffold and controls generation' do
    before(:each) do
      render :partial => 'article/show_controls_no_scaffold'
    end

    it_should_behave_like 'always'
    
    describe 'rendering an object with no errors' do
      it_should_behave_like 'controls mode'
    end
  
    describe 'rendering an object with errors' do
      def article
        super.title = nil # make the article invalid
        super
      end
      it_should_behave_like 'controls mode'
      it_should_behave_like 'controls mode without scaffold'
      it_should_behave_like 'error message'
      it_should_behave_like 'no error class'
    end
    
  end

  describe 'with no scaffold and no controls generation' do
    before(:each) do
      render :partial => 'article/show_no_controls_no_scaffold'
    end

    it_should_behave_like 'always'
    
    describe 'rendering an object with no errors' do
      it_should_behave_like 'no controls mode'
    end
  
    describe 'rendering an object with errors' do
      def article
        super.title = nil # make the article invalid
        super
      end
      it_should_behave_like 'no controls mode'
      # it_should_behave_like 'no error'
      # it_should_behave_like 'no controls mode without scaffold'
    end
    
  end

  describe 'with no controls generation and block given' do
    before(:each) do
      render :partial => 'article/show_no_controls_block_given'
    end

    it_should_behave_like 'always'
    
    describe 'rendering an object with no errors' do
      it_should_behave_like 'no controls mode'

    end
  
    describe 'rendering an object with errors' do
      def article
        super.title = nil # make the article invalid
        super
      end
      it_should_behave_like 'no controls mode'
      # it_should_behave_like 'no error'
      # it_should_behave_like 'no controls mode without scaffold'
    end
    
  end
  
end
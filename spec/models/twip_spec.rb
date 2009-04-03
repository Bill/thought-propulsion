require File.dirname(__FILE__) + '/../spec_helper'

module Propel
  # Dynamically, globally enable/disable breakpoints
  DEBUGGING = false
  # Invoke this (dynamically) when you need to turn on debugging
  #  Propel.const_set(:DEBUGGING, true)
  # And put this at points where you want to break:
  #  debugger if Propel::DEBUGGING
end

describe Twip do
  
  fixtures :users, :images
  
  module UploadedImage
    def body
      "<p>my self-portrait:<img src='#{image_placement_url}'></img></p>"
    end

    def image_placement
      returning( @image_placement ||= ImagePlacement.new ) do | image_placement |
        if( image_placement.new_record?)
          image_placement.image = image
          image_placement.save
          # no Twip associated yet
        end
      end
    end
    def unauthenticated_image_url
      "http://images.#{@envsub}twipl.com/#{image.id}/#{image.filename}"
    end
    def image_placement_url
      "/image_placements/#{image_placement.id}"
    end
  end
  
  shared_examples_for 'successfully creating a Twip' do
    it 'should return true from Twip#save' do
      @save_result.should be_true
    end
    it 'should have no errors on Twip' do
      @twip.errors.should be_empty
    end
    it 'should save Twip' do
      @twip.should_not be_new_record
    end
  end
  
  shared_examples_for 'noticing ImagePlacements' do
    it 'should have no Image URLs' do
      @twip.body.include?( unauthenticated_image_url).should_not be_true
    end
    it 'should have ImagePlacement URLs' do
      @twip.body.include?( image_placement_url).should be_true
    end
    it 'should create an ImagePlacement in memory for the Image' do
      @twip.image_placements.length.should == 1
    end
    it 'should create an ImagePlacement in the database for the Image' do
      @twip.image_placements.count.should == 1
    end
  end
  
  shared_examples_for 'illegal ImagePlacements' do
    it 'should have ImagePlacement URLs' do
      @twip.body.include?( image_placement_url).should be_true
    end
    it 'should create an ImagePlacement in memory for the Image' do
      # the ImagePlacement is associated so we can scan it for errors, but it isn't saved.
      @twip.image_placements.length.should == 1
    end
    it 'should not create an ImagePlacement in the database for the Image' do
      @twip.image_placements.count.should == 0
    end
    it 'should capture errors on ImagePlacement' do
      @twip.image_placements[0].errors.should_not be_empty
    end
    it 'should return false from Twip#save' do
      @save_result.should be_false
    end
  end

  before(:each) do
    @envsub, port = Propel::EnvironmentSubdomains::envsub
  end

  describe 'when creating a new Twip' do
    def before_save
      # debugging hook
    end
    before(:each) do
      @envsub, port = Propel::EnvironmentSubdomains::envsub
      @twip = Twip.new( :title => 'dig', :body=>body)
      @twip.author = users(:fred)
      before_save
      @save_result = @twip.save
    end
    
    describe 'with no uploaded image' do
      def body
        "<p>future home of self-portrait</p>"
      end
      it_should_behave_like 'successfully creating a Twip'
    end
    
    describe 'with an uploaded image' do

      include UploadedImage
      
      describe 'that is owned by the Twip author' do
        def image
          images(:freds)
        end

        it_should_behave_like 'successfully creating a Twip'
      
        it_should_behave_like 'noticing ImagePlacements'
      end

      describe 'that is public' do
        def image
          images(:public)
        end

        it_should_behave_like 'successfully creating a Twip'
        it_should_behave_like 'noticing ImagePlacements'
      end

      describe 'that is neither public nor owned by the Twip author' do
        def image
          images(:sallys)
        end

        it_should_behave_like 'illegal ImagePlacements'
      end
      
    end
  end

  describe 'when updating a Twip' do
    before(:each) do
      @twip = Twip.new( :title => 'dig', :body=>'')
      @twip.author = users(:fred)
      @twip.save!
      @twip.body = body
      @save_result = @twip.save
    end
    
    describe 'with an uploaded image' do
    
      include UploadedImage

      describe 'that is owned by the Twip author' do
        def image
          images(:freds)
        end

        it_should_behave_like 'successfully creating a Twip'
      
        it_should_behave_like 'noticing ImagePlacements'
      end

      describe 'that is public' do
        def image
          images(:public)
        end

        it_should_behave_like 'successfully creating a Twip'
        it_should_behave_like 'noticing ImagePlacements'
      end

      describe 'that is neither public nor owned by the Twip author' do
        def image
          images(:sallys)
        end

        it_should_behave_like 'illegal ImagePlacements'
      end
      
    end
    
  end
end
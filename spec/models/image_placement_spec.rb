require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagePlacement do

  fixtures :images

  before(:each) do
    @valid_attributes = {
      :image_id => images(:freds).id
    }
  end

  it "should create a new instance given valid attributes" do
    ImagePlacement.create!(@valid_attributes)
  end
end

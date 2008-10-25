require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagePlacement do
  before(:each) do
    @valid_attributes = {
      :twip_id => "1",
      :image_id => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    ImagePlacement.create!(@valid_attributes)
  end
end

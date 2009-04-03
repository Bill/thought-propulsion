require 'aws/s3'
module ImagesHelper
  def image_src_url( image )
    # image.s3_url()
    #image.authenticated_s3_url( :expires_in => 10.minutes)
    envsub, port = Propel::EnvironmentSubdomains::envsub
    image.authenticated_virtual_hosting_s3_url( "images.#{envsub}twipl.com", :expires_in => 10.minutes)
    # AWS::S3::S3Object.url_for( image.full_filename, '',  :expires_in => 10.minutes)
  end
end
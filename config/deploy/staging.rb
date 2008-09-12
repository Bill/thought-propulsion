set :rails_env, 'staging'

set :branch, "deploy"

# Your EC2 instances. Use the ec2-xxx....amazonaws.com hostname, not
# any other name (in case you have your own DNS alias) or it won't
# be able to resolve to the internal IP address.
# Your EC2 instances
set :domain, "ec2-75-101-210-134.compute-1.amazonaws.com"

role :web,      domain
role :app,      domain
role :db,       domain, :primary => true
role :memcache, domain
# role :db,       "ec2-56-xx-xx-xx.z-1.compute-1.amazonaws.com", :primary => true, :ebs_vol_id => 'vol-12345abc'
# optionally, you can specify Amazon's EBS volume ID if the database is persisted 
# via Amazon's EBS.  See the main README for more information.

# EC2 on Rails config. 
# NOTE: Some of these should be omitted if not needed.
set :ec2onrails_config, fetch(:ec2onrails_config).merge(
  # S3 bucket and "subdir" used by the ec2onrails:db:restore task
  # NOTE: this only applies if you are not using EBS
  :restore_from_bucket => "propel-staging",
  :restore_from_bucket_subdir => "db-archive/2008-09-11--17-50-27",
  
  # S3 bucket and "subdir" used by the ec2onrails:db:archive task
  # This does not affect the automatic backup of your MySQL db to S3, it's
  # just for manually archiving a db snapshot to a different bucket if 
  # desired.
  # NOTE: this only applies if you are not using EBS
  :archive_to_bucket => "propel-staging",
  :archive_to_bucket_subdir => "db-archive/#{Time.new.strftime('%Y-%m-%d--%H-%M-%S')}"
  )

# we stick this at the end here rather than in Capfile so that multistage will work
# see http://groups.google.com/group/ec2-on-rails-discuss/browse_thread/thread/19b17d0c92b5108
require 'ec2onrails/recipes'
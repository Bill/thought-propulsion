# see the deploy directory for stage-specific recipes
require 'capistrano/ext/multistage'

set :application, "propel"

set :scm, :git
set :scm_passphrase, "Loj8eWWfJwGB"
set :deploy_via, :copy
set :git_shallow_clone, 1
set :git_enable_submodules, 1

set :repository,  "git@github.com:Bill/thought-propulsion.git"
# set :branch, "deploy"

ssh_options[:paranoid] = false

# NOTE: for some reason Capistrano requires you to have both the public and
# the private key in the same folder, the public key should have the 
# extension ".pub".
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/id_rsa-gsg-keypair"]

# EC2 on Rails config. 
# NOTE: Some of these should be omitted if not needed.
set :ec2onrails_config, {
  # Set a root password for MySQL. Run "cap ec2onrails:db:set_root_password"
  # to enable this. This is optional, and after doing this the
  # ec2onrails:db:drop task won't work, but be aware that MySQL accepts 
  # connections on the public network interface (you should block the MySQL
  # port with the firewall anyway). 
  # If you don't care about setting the mysql root password then remove this.
  # :mysql_root_password => "your-mysql-root-password",
  
  # Any extra Ubuntu packages to install if desired
  # If you don't want to install extra packages then remove this.
  # :packages => ["logwatch", "imagemagick"],
  :packages => ["logwatch", "imagemagick"],
  
  # Any extra RubyGems to install if desired: can be "gemname" or if a 
  # particular version is desired "gemname -v 1.0.1"
  # If you don't want to install extra rubygems then remove this
  :rubygems => ["rails -v '2.1.1'", "ruby-openid -v '>= 2.1.2'", "mislav-will_paginate -v'>= 2.3.2' --source http://gems.github.com", "capistrano -v '2.4.3'"],
  
  # Defines the web proxy that will be used.  Choices are :apache or :nginx
  :web_proxy_server => :apache,
  
  # extra security measures are taken if this is true, BUT it makes initial
  # experimentation and setup a bit tricky.  For example, if you do not
  # have your ssh keys setup correctly, you will be locked out of your
  # server after 3 attempts for upto 3 months.  
  :harden_server => false,
  
  # Set the server timezone. run "cap -e ec2onrails:server:set_timezone" for 
  # details
  :timezone => "US/Pacific",
  
  # Files to deploy to the server (they'll be owned by root). It's intended
  # mainly for customized config files for new packages installed via the 
  # ec2onrails:server:install_packages task. Subdirectories and files inside
  # here will be placed in the same structure relative to the root of the
  # server's filesystem. 
  # If you don't need to deploy customized config files to the server then
  # remove this.
  :server_config_files_root => "../server_config",
  
  # If config files are deployed, some services might need to be restarted.
  # If you don't need to deploy customized config files to the server then
  # remove this.
  :services_to_restart => %w(apache2 postfix sysklogd),
  
  # Set an email address to forward admin mail messages to. If you don't
  # want to receive mail from the server (e.g. monit alert messages) then
  # remove this.
  :mail_forward_address => "propeller@thoughtpropulsion.com",
  
  # Set this if you want SSL to be enabled on the web server. The SSL cert 
  # and key files need to exist on the server, The cert file should be in
  # /etc/ssl/certs/default.pem and the key file should be in
  # /etc/ssl/private/default.key (see :server_config_files_root).
  :enable_ssl => true
}

namespace :propel do
  task :pwd, :roles => :app do
    run 'pwd'
  end  
  task :load_schema_and_seed, :roles => :app do
    run "cd #{File.join( deploy_to, 'current')} && export RAILS_ENV=#{rails_env} && rake db:schema:load db:seed"
  end
end
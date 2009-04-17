# usage (in development): rake db:seed RAILS_ENV=development
# if you don't pass the RAILS_ENV it assumes productions which is um wrong.

envsub, port = Propel::EnvironmentSubdomains::envsub

# see seed-fu plugin
%w{
www
dev
staging
test
images
bill
billb
billburcham
burcham
propel
joyomi
thoughtpropulsion
thought-propulsion
writerocket
write-rocket
twipl
showzee
focalizr
memerocket
meme-rocket
starsatnight
}.each do |name|
  # reserve these nicknames by associating them with OpenID's under our own domain
  User.seed(:nickname, :normalized_identity_url) do |s|
    s.nickname = name
    s.identity_url = "http://#{name}.thoughtpropulsion.com"
  end
end

User.seed(:nickname) do |s|
  s.nickname = 'propeller'
  s.identity_url = 'http://memerocket.com'
  envsub, port = Propel::EnvironmentSubdomains::envsub
  s.alternate_domain = "blog.#{envsub}thoughtpropulsion.com"
  s.admin = true
end
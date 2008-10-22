# see seed-fu plugin
%w{
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
  s.identity_url = 'http://meme-rocket.com'
  envsub, port = Propel::EnvironmentSubdomains::envsub
  s.alternate_domain = "blog.#{envsub}thoughtpropulsion.com"
  s.admin = true
end
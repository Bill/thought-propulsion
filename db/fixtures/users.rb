# see seed-fu plugin
%w{
bill
billb
billburcham
burcham
propeller
propel
joyomi
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
  User.seed(:nickname, :normalized_identity_url) do |s|
    s.nickname = name
    s.identity_url = "http://#{name}.myopenid.com"
  end
end

User.seed(:nickname, :normalized_identity_url) do |s|
  s.nickname = 'thoughtpropulsion'
  s.identity_url = 'http://meme-rocket.com'
end
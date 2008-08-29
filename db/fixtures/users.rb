# see seed-fu plugin
%w{
bill
billb
billburcham
burcham
propeller
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
  User.seed(:nickname, :identity_url) do |s|
    s.nickname = name
    s.identity_url = "http://#{name}.myopenid.com"
  end
end
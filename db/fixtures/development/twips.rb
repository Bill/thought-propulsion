# You must explicitly run with rake db:seed RAILS_ENV=development for this seed to be loaded
require 'lorem'
thoughtpropulsion = User.find_by_nickname 'thoughtpropulsion'
(0..1).each do |n|
  twip = Twip.seed( :title) do |t|
    # need to make something differ in each record so it will be saved (by seed) so make 
    # title progressively longer
    t.title = Lorem::Base.new('chars', 5 + n).output
    t.body = Lorem::Base.new('paragraphs', 2).output
  end
  twip.owner = thoughtpropulsion
  twip.save!
end
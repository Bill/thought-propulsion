class Day
  def self.all( publisher, viewer, twip_limit = 3)
    twips = publisher.twips.access_public_or_shared_with( viewer).find( :all, :limit => twip_limit, :order => 'created_at DESC') || []
    twips.group_by do | twip |
      Time.utc( twip.updated_at.year, twip.updated_at.month, twip.updated_at.day )
    end.collect do | date, twips |
      new( date, twips)
    end
  end
  
  attr_reader :date, :twips
  
  def initialize( date, twips )
    @date = date
    @twips = twips
  end
end
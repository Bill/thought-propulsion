class ContactController < ThoughtPropulsionApplicationController
  
  def index
    @vcard = {
      :fn => 'Thought Propulsion',
      # FIXME: url helper
      :url => url_for( '/'),
      :addresses => [
        { :type => 'meeting', :street_address => '622 SE Grand Ave.', :locality => 'Portland', :region => 'Oregon', :postal_code => '97214', :country_name => 'USA'},
        { :type => 'postal', :post_office_box => '19863', :locality => 'Portland', :region => 'Oregon', :postal_code => '97280', :country_name => 'USA'}
        ],
      :emails => [
        { :type => 'inquiries', :address => 'propeller@thoughtpropulsion.com'}
        ],
      :telephones => [
        {
          :type => 'work',
          :value => '503.720.2991'
        }]
    }
  end
end
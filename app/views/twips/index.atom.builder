xml.feed( :xmlns => 'http://www.w3.org/2005/Atom') do
  xml.title('Twips')
  xml.subtitle('all the twips that&apos;s fit to twip')
  xml.link( :href => twips_url, :rel=> 'self')
  xml.link( :href => home_url)
  xml.updated( Time.now)
  xml.id('123')
  xml.link( :rel => 'first', :href => twips_url)
  xml.link( :rel => 'next', :href => twips_url)
  xml.link( :rel => 'last', :href => twips_url)
  xml << render( :partial => 'show', :collection => @twips)
end
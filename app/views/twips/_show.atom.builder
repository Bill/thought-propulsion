feed.entry(show) do |entry|
  entry.title(show.title)
  entry.content( :type => 'xhtml') do | content |
    # we must turn all the relative image_placement URLs into absolute ones otherwise feed readers
    # will never see our images
    x = "<root>#{show.body}</root>".to_libxml_doc.root
    (x/'//img/@src').each do | href |
      id = href.inner_xml[ /.*\/image_placements\/(\d+)\/?$/, 1]
      unless id.nil?
        ip = ImagePlacement.find( id)
        href.value = image_placement_url( ip )
      end
    end
    content << (x/'/root').inner_xml
  end

  entry.author do |author|
    author.name( show.author.nickname)
    author.uri( twips_url( :host => show.author.best_domain ) )
  end
end
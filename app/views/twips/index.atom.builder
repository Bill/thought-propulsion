atom_feed do |feed|
  feed.title( @publisher.best_domain)
  feed.subtitle( :type => 'xhtml' ) do | sub |
    sub << "Powered by #{link_to 'Twipl', twipl_home_url}"
  end
  feed.updated((@twips.first.updated_at))
  render :partial => 'show', :collection => @twips, :locals => { :feed => feed}
end
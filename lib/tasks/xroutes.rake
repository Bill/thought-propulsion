require 'ruby-debug'
Debugger.start

desc 'Print out all defined routes in match order, with names.'
task :xroutes => :environment do
  routes = ActionController::Routing::Routes.routes.collect do |route|
    # relies on our monkey patch to Route
    # TODO: get name e.g. name = ( route.conditions[:route_name] || '').to_s
    verb = route.conditions[:method].to_s.upcase
    route.conditions.delete(:method) # don't show it again
    segs = route.segments.inject("") { |str,s| str << s.to_s }
    segs.chop! if segs.length > 1
    reqs = route.requirements.empty? ? "(no requirements)" : route.requirements.inspect
    # requirements actully contains requirements and defaults. Rails treats Regexp's in requirements as
    # requirements and constants as defaults
    (reqs, defaults) = (route.requirements || {}).partition{|(k,v)| Regexp === v}
    reqs = reqs.empty? ? '(no requirements)' : reqs.inspect
    defaults = defaults.empty? ? '(no defaults)' : defaults.inspect
    conds = route.conditions.empty? ? "(no conditions)" : route.conditions.inspect
    {:verb => verb, :segs => segs, :reqs => reqs, :defaults=> defaults, :conds => conds}
  end
  verb_width = routes.collect {|r| r[:verb]}.collect {|v| v.length}.max
  segs_width = routes.collect {|r| r[:segs]}.collect {|s| s.length}.max
  reqs_width = routes.collect {|r| r[:reqs]}.collect {|s| s.length}.max
  defaults_width = routes.collect {|r| r[:defaults]}.collect {|s| s.length}.max
  conds_width = routes.collect {|r| r[:conds]}.collect {|s| s.length}.max
  routes.each do |r|
    puts "#{r[:verb].ljust(verb_width)} #{r[:segs].ljust(segs_width)}  #{r[:reqs].ljust(reqs_width)} #{r[:defaults].ljust(defaults_width)} #{r[:conds].ljust(conds_width)}"
  end
end
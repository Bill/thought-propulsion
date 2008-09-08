# Rails suggests that we users extend route recognition by providing our own 
# RouteSet#extract_request_environment and Route#recognition_conditions. 
# That's a really nice extension point. It lets us extend routing conditions
# to more than just :method. Stuff like :host and :scheme etc.
# But then Rails ignores those extensions when constructing URL's internally.
# See how url_rewriter.rb UrlRewriter#rewrite_path sends 
# @request.symbolized_path_parameters to Routing::Routes.generate, 
# but the request got its path_parameters from RouteSet#recognize here:
#   def recognize(request)
#     params = recognize_path(request.path, extract_request_environment(request))
#     request.path_parameters = params.with_indifferent_access
#     …
# What this little patch does is intervenes on the setting of Request 
# path_parameters, injecting the extra parameters gleaned from 
# extract_request_environment. In a vanilla Rails environment this gives you
# :method but in a user-extension scenario you get all the user-defined goodness.
module Propel
  module MultiDomainRouting
    # include this module in ActionController::AbstractRequest after our ExtractHostParameter extension is loaded
    module InjectHostParameterIntoURLGeneration
      def self.included( other)
        other.alias_method_chain :path_parameters=, :host_parameter
      end
      
      def path_parameters_with_host_parameter=(parameters) #:nodoc:
        extra_parameters = ActionController::Routing::Routes.extract_request_environment( self )
        
        # some code such as OpenID::Consumer#complete require the caller (controller) to do this first
        # parameters = params.reject{|k,v| request.path_parameters[k] }
        # Well, unless we convert all our keys to strings then that filter won't find e.g. :host
        # because :host != "host"
        # Also while we're at it we're going to remove nil values. If you have a look at that code
        # example above, you'll see that while it ought to use request.has_key?(k) it doesn't. I'm
        # concerned lots of code copied that example so I'm just going to avoid that problem here.
        extra_parameters = extra_parameters.inject( {}){ |newhash, (k,v) | v.nil? ? newhash.delete(k) : newhash[k.to_s] = v; newhash}
        
        self.path_parameters_without_host_parameter=( extra_parameters.merge( parameters) )
      end
    end
  end
end
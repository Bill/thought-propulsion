module DomainName
  
  def valid_domain?( domain)
    # stealing specs from Chris Reinhardt's Regexp-Common-dns module on CPAN
    # claims it's a pragmatic combination of rfc1035, and rfc2181
    # domain may contain up to 255, period-separated labels
    return false if domain.nil?
    labels = domain.split('.')
    return false if labels.nil? || labels.length < 1 || labels.length > 255
    return labels.all?{|label| valid_label? label}
  end
  
  def valid_label?( label)
    # may contain up to 63 lowercase letters, digits, or underscores
    return false if label.nil? || label.length < 1 || label.length > 63
    !!( match = label.match( /([[:lower:]]|[[:digit:]]|-|_)+/) ) && match[0].length == label.length
  end
  
  module_function :valid_domain?
  module_function :valid_label?
end
module DomainName
  
  LABEL_INSTRUCTIONS = 'may contain only lowercase letters, digits, underscores and hyphens. Max length is 63'
  
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
  
  # if com and net are top-level domains, then labels at the other end of the name are bottom-level ones
  # this routine takes a domain name and returns the left-most label
  def bottom_label( domain)
    domain.split('.')[0]
  end
  
  module_function :valid_domain?
  module_function :valid_label?
  module_function :bottom_label
end
module URL
  def normalize_url( url)
    url = url[0..-2] unless url.nil? || (url[-1].chr != '/')
    # see http://gbiv.com/protocols/uri/rfc/rfc3986.html#scheme
    scheme = /[[:alpha:]]([[:alpha:]]|[[:digit:]]|\+|\-|\.)*:/.match url
    if scheme
      url
    else
      'http://' + url
    end
  end
  module_function :normalize_url
end
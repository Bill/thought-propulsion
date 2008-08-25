module Nonce
  def generate
    schars = "24356789abcdefghijkmnpqrstuvwxyz" # no zeros, oh's, 1's or l's
    verifier = ""
    1.upto(12) { verifier += schars[rand(schars.length),1] } # 32 ^ 12 possible combinations -- plenty
    return CGI.escape( verifier) # escape it for good measure!
  end
  module_function :generate
end
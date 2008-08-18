# The purpose of this controller is to allow us to dynamically generate our stylesheets. This lets us
# use the full power of Ruby to e.g. define color values one time and reuse them (via variables), to
# define basic dimensions and then compute derived dimensions from those.
class ApplicationStylesheetController < ApplicationController
  
  def show
    
    define_palette
    
    respond_to do |wants|
      wants.css {}
    end    
  end
  
  protected

  UNDEFINED = ''
  
  def define_palette
    # color palettes
    # read this as "c" for "color" followed by either "b" for base hue or "a" for the analog (neighbor)
    # or 't' for the complement (user sparingly!).
    # after that comes an optional specification describing the addition of black or white e.g.
    # k1 is one "unit" toward black ("k" from the CMYK tradition); w4 is four "units" toward white
    # You might want to use http://slayeroffice.com/tools/color_palette/ to generate palettes.
    # The purpose of these variables, however is to allow you to change the palette
    # without having to search and replace everything in the CSS.
    @c_b = '#1F2323'
    @c_b_w1 = '#575A5A'
    @c_b_w2 = '#909292'
    @c_b_w3 = '#C7C8C8'
    @c_b_w4 = '#E9EAEA'
    # @c_b_w5 is simply 'white' in CSS so we don't need a variable for it here
    @c_b_k1 = '#1A1E1E'
    @c_b_k2 = '#171A1A'
    @c_b_k3 = '#101212'
    @c_b_k4 = '#080909'
    @c_b_k5 = '#030404'
    
    @c_a = UNDEFINED
    @c_a_w1 = UNDEFINED
    @c_a_w2 = UNDEFINED
    @c_a_w3 = UNDEFINED
    @c_a_w4 = UNDEFINED
    # @c_a_w5 is simply 'white' in CSS so we don't need a variable for it here
    @c_a_k1 = UNDEFINED
    @c_a_k2 = UNDEFINED
    @c_a_k3 = UNDEFINED
    @c_a_k4 = UNDEFINED
    # @c_a_k5 is simply 'black' in CSS so we don't need a variable for it here

    @c_t = '#14ACE1'
    @c_t_w1 = '#4FC1E9'
    @c_t_w2 = '#8AD6F1'
    @c_t_w3 = '#C4EAF7'
    @c_t_w4 = '#E8F7FD'
    # @c_t_w5 is simply 'white' in CSS so we don't need a variable for it here
    @c_t_k1 = '#1192BF'
    @c_t_k2 = '#0F81A9'
    @c_t_k3 = '#0A5671'
    @c_t_k4 = '#052B38'
    @c_t_k5 = '#021117'
  end
end
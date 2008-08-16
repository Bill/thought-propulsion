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
    @c_b = UNDEFINED
    @c_b_w1 = UNDEFINED
    @c_b_w2 = UNDEFINED
    @c_b_w3 = UNDEFINED
    @c_b_w4 = UNDEFINED
    # @c_b_w4 is simply 'white' in CSS so we don't need a variable for it here
    @c_b_k1 = UNDEFINED
    @c_b_k2 = UNDEFINED
    @c_b_k3 = UNDEFINED
    @c_b_k4 = '#1F2323'
    # @c_b_k5 is simply 'black' in CSS so we don't need a variable for it here
    
    @c_a = UNDEFINED
    @c_a_w1 = UNDEFINED
    @c_a_w2 = UNDEFINED
    @c_a_w3 = UNDEFINED
    @c_a_w4 = UNDEFINED
    # @c_a_w4 is simply 'white' in CSS so we don't need a variable for it here
    @c_a_k1 = UNDEFINED
    @c_a_k2 = UNDEFINED
    @c_a_k3 = UNDEFINED
    @c_a_k4 = UNDEFINED
    # @c_a_k5 is simply 'black' in CSS so we don't need a variable for it here
  end
end
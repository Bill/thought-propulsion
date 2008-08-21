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
    @c_b_w1 = '#4c4f4f'
    @c_b_w2 = '#797b7b'
    @c_b_w3 = '#a5a7a7'
    @c_b_w4 = '#d2d3d3'
    
    @c_b_k1 = '#191c1c'
    @c_b_k2 = '#131515'
    @c_b_k3 = '#0c0e0e'
    @c_b_k4 = '#060707'
    
    @c_a = '#f8510b'
    @c_a_w1 = '#f9943c'
    @c_a_w2 = '#fbc66d'
    @c_a_w3 = '#fce89d'
    @c_a_w4 = '#fefcce'
    @c_a_w5 = '#ffffff'
    # @c_a_w5 is simply 'white' in CSS so we don't need a variable for it here (lies!)
    @c_a_k1 = '#c63509'
    @c_a_k2 = '#951e07'
    @c_a_k3 = '#630d04'
    @c_a_k4 = '#320302'
    @c_a_k5 = '#000000'

    @c_t = '#597eaa'
    @c_t_w1 = '#7a98bb'
    @c_t_w2 = '#9bb2cc'
    @c_t_w3 = '#bdcbdd'
    @c_t_w4 = '#dee5ee'

    @c_t_k1 = '#476588'
    @c_t_k2 = '#354c66'
    @c_t_k3 = '#243244'
    @c_t_k4 = '#121922'
  end
end
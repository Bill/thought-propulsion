# The purpose of this controller is to allow us to dynamically generate our stylesheets. This lets us
# use the full power of Ruby to e.g. define color values one time and reuse them (via variables), to
# define basic dimensions and then compute derived dimensions from those.
class StylesheetsController < ApplicationController
  
  COLORS = {
    # color palettes
    # read this as "c" for "color" followed by either "b" for base hue or "a" for the analog (neighbor)
    # or 't' for the complement (user sparingly!).
    # after that comes an optional specification describing the addition of black or white e.g.
    # k1 is one "unit" toward black ("k" from the CMYK tradition); w4 is four "units" toward white
    # You might want to use http://slayeroffice.com/tools/color_palette/ to generate palettes.
    # The purpose of these variables, however is to allow you to change the palette
    # without having to search and replace everything in the CSS.
    :c_b => '#1F2323',
    :c_b_w1 => '#2c2c2c',
    :c_b_w2 => '#797b7b',
    :c_b_w3 => '#a5a7a7',
    :c_b_w4 => '#d2d3d3',
    
    :c_b_k1 => '#191c1c',
    :c_b_k2 => '#131515',
    :c_b_k3 => '#0c0e0e',
    :c_b_k4 => '#060707',
    
    :c_a => '#f8510b',
    :c_a_w1 => '#f9943c',
    :c_a_w2 => '#fbc66d',
    :c_a_w3 => '#fce89d',
    :c_a_w4 => '#fefcce',
    :c_a_w5 => '#ffffff',
    # :c_a_w5 is simply 'white' in CSS
    :c_a_k1 => '#c63509',
    :c_a_k2 => '#951e07',
    :c_a_k3 => '#630d04',
    :c_a_k4 => '#320302',
    :c_a_k5 => '#000000',

    :c_t => '#7eadde',
    :c_t_w1 => '#98bde5',
    :c_t_w2 => '#b2ceeb',
    :c_t_w3 => '#cbdef2',
    :c_t_w4 => '#e5eff8',

    :c_t_k1 => '#658ab2',
    :c_t_k2 => '#4c6885',
    :c_t_k3 => '#324559',
    :c_t_k4 => '#19232c'
  }

  def self.base_colors
    subset( 'c_b')
  end

  def self.analogous_colors
    subset( 'c_a')
  end

  def self.complementary_colors
    subset( 'c_t')
  end
  
  layout false
  
  def application
    
    define_palette
    
    respond_to do |wants|
      wants.css
    end
  end
  
  protected
  
  def define_palette
    # make COLORS into instance variables
    COLORS.each do | color_name, color_value|
      instance_eval "@#{color_name.to_s} = #{color_value.inspect}"
    end
  end
  
  private
  def self.subset( pre)
    Hash[ * COLORS.select{|k,v| k.to_s.match(/^#{pre}/)}.flatten ]
  end
end
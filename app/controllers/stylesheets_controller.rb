# The purpose of this controller is to allow us to dynamically generate our stylesheets. This lets us
# use the full power of Ruby to e.g. define color values one time and reuse them (via variables), to
# define basic dimensions and then compute derived dimensions from those.
class StylesheetsController < ApplicationController
  
  COLORS = {
    # color palettes
    # read this as "c" for "color" followed by either "a", "b" or "c" to select a hue family.
    # After that comes an optional specification describing the addition of black or white e.g.
    # k1 is one "unit" toward black ("k" from the CMYK tradition); w4 is four "units" toward white
    # You might want to use http://slayeroffice.com/tools/color_palette/ to generate palettes.
    # The purpose of these variables, however is to allow you to change the palette
    # without having to search and replace everything in the CSS.
    :c_a => '#1F2323',
    :c_a_w1 => '#2c2c2c',
    :c_a_w2 => '#797b7b',
    :c_a_w3 => '#a5a7a7',
    :c_a_w4 => '#d2d3d3',
    
    :c_a_k1 => '#191c1c',
    :c_a_k2 => '#131515',
    :c_a_k3 => '#0c0e0e',
    :c_a_k4 => '#060707',
    
    :c_b => '#f8510b',
    :c_b_w1 => '#f9943c',
    :c_b_w2 => '#fbc66d',
    :c_b_w3 => '#fce89d',
    :c_b_w4 => '#fefcce',
    :c_b_w5 => '#ffffff',
    # :c_b_w5 is simply 'white' in CSS
    :c_b_k1 => '#c63509',
    :c_b_k2 => '#951e07',
    :c_b_k3 => '#630d04',
    :c_b_k4 => '#320302',
    :c_b_k5 => '#000000',

    :c_c => '#7eadde',
    :c_c_w1 => '#98bde5',
    :c_c_w2 => '#b2ceeb',
    :c_c_w3 => '#cbdef2',
    :c_c_w4 => '#e5eff8',

    :c_c_k1 => '#658ab2',
    :c_c_k2 => '#4c6885',
    :c_c_k3 => '#324559',
    :c_c_k4 => '#19232c'
  }

  def self.a_colors
    subset( 'c_a')
  end

  def self.b_colors
    subset( 'c_b')
  end

  def self.c_colors
    subset( 'c_c')
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
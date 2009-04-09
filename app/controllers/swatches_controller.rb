class SwatchesController < ApplicationController
  layout false
  
  ORDER = %w(_k5 _k4 _k3 _k2 _k1 * _w1 _w2 _w3 _w4 _w5).collect{|suf| suf == '*' ? '' : suf}
  
  def index
     # @base_colors = ORDER.collect{ | suf | key = "c_b#{suf}".to_sym; [key, StylesheetsController::base_colors[key] ] }
     @base_colors = sort_colors( 'c_b', StylesheetsController::base_colors)
     @analogous_colors = sort_colors( 'c_a', StylesheetsController::analogous_colors)
     @complementary_colors = sort_colors( 'c_t', StylesheetsController::complementary_colors)
  end
  private
  def sort_colors( pre, colors)
    ORDER.collect{ | suf | key = "#{pre}#{suf}".to_sym; [key, colors[key] ] }
  end
end
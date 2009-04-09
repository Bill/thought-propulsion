class SwatchesController < ApplicationController
  layout false
  
  ORDER = %w(_k5 _k4 _k3 _k2 _k1 * _w1 _w2 _w3 _w4 _w5).collect{|suf| suf == '*' ? '' : suf}
  
  def index
     @a_colors = sort_colors( 'c_a', StylesheetsController::a_colors)
     @b_colors = sort_colors( 'c_b', StylesheetsController::b_colors)
     @c_colors = sort_colors( 'c_c', StylesheetsController::c_colors)
  end
  private
  def sort_colors( pre, colors)
    ORDER.collect{ | suf | key = "#{pre}#{suf}".to_sym; [key, colors[key] ] }
  end
end
class MapController < ApplicationController
  
  def svgmap
    
    @svg_map = SvgMap.new(params[:x1], 
                          params[:y1], 
                          params[:x2], 
                          params[:y2],
                          params[:h],
                          params[:w])
    svg = @svg_map.render
    send_data(svg, :filename => 'map.svg', :type => "image/svg+xml")

  end

  def map
    
    @x1 = params[:x1]
    @y1 = params[:y1]
    @x2 = params[:x2]
    @y2 = params[:y2]
    @w  = params[:w]
    @h  = params[:h]
    
  end

end

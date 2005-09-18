class SvgMap
  require 'svg/svg'
  require 'svg_map_edge'
  require 'svg_map_node'

  @@line_width = 3

  @@colours = {
    'white' => '#ffffff',
    'black' => '#000000',
    
    '1' => '#bb6600',
    '2' => '#ff0000',
    '3' => '#ffff00',
    '4' => '#00dd00',
    '5' => '#ff7700',
    '6' => '#ff9999',
    '7' => '#dddddd',
    '8' => '#aa0044',
    '9' => '#000000',
    '10' => '#0000bb',
    '11' => '#0077ff',
    '12' => '#00ddcc',
    
    'hi' => '#dddddd',
  }
  
  def initialize(x1, y1, x2, y2, h, w)
    @x1, @y1 = x1, y1
    @x2, @y2 = x2, y2
    @h, @w   = h, w
  end
  
  def render
    
    sql = "SELECT edge_id as id, 
                  a.node_id as nida,
                  b.node_id as nidb,
                  a.node_osx as nax, 
                  a.node_osy as nay, 
                  b.node_osx as nbx, 
                  b.node_osy as nby, 
                  nla.nodl_line_id as l
             FROM edges
             JOIN nodes a
               ON a.node_id = edge_node_a_id
             JOIN nodes b
               ON b.node_id = edge_node_b_id
             JOIN node_lines nla
               ON nla.nodl_node_id = a.node_id
            WHERE edge_edgt_id = 1 
              AND nodl_line_id IS NOT NULL
              AND ( edge_node_a_id IN ( SELECT node_id
                                          FROM nodes,
                                               nodesets
                                         WHERE node_nods_id = nods_id
                                           AND node_ntyp_id = 1
                                           AND node_osx >= :x1
                                           AND node_osx <= :x2
                                           AND node_osy >= :y1
                                           AND node_osy <= :y2 ) )
            ORDER BY l"
    
    conn = ActiveRecord::Base.connection.connection
    cursor = conn.parse(sql)
    cursor.bind_param(':x1', @x1.to_i, Fixnum)
    cursor.bind_param(':y1', @y1.to_i, Fixnum)
    cursor.bind_param(':x2', @x2.to_i, Fixnum)
    cursor.bind_param(':y2', @y2.to_i, Fixnum)
    cursor.exec
    
    seen = Hash.new
    edges = Array.new
    
    cursor.fetch { |r| 
      edge = SvgMapEdge.new(r) 
  
      if ( !(seen.has_value?(edge.key) && seen[edge.key].has_value?(edge.line)) )
        edges.push(edge)
        
        if (!seen.has_key?(edge.key))
          seen[edge.key] = Hash.new
        end
        
        if (seen[edge.key].has_value?(edge.line))
          seen[edge.key][edge.line] += 1
        else
          seen[edge.key][edge.line] = 1
        end
        
      end
      
    }
    
    x_factor = @w.to_f / (@x2.to_i - @x1.to_i);
    y_factor = @h.to_f / (@y2.to_i - @y1.to_i);

    svg = SVG.new(@w, @h)

    edges.each { |edge|

      if (seen[edge.key].length > 1) 

        # construct a vector such that the dot product is 0 (orthogonal),
        # and then adjust its length to be the skew value.
        
        x = edge.nax - edge.nbx
        y = edge.nby - edge.nay

        i = (@@line_width.to_f / (Math.sqrt(x**2 + y**2)))
        
        x_skew = y.to_f * i / x_factor
        y_skew = x.to_f * i / y_factor

        # case of 2 parallel edges
        if (seen[edge.key].length == 2)

          if (edge.line == seen[edge.key].keys[0])
            x_skew = -(0.5 * x_skew)
            y_skew = -(0.5 * y_skew)
          end

          if (edge.line == seen[edge.key].keys[1])
            x_skew = (0.5 * x_skew)
            y_skew = (0.5 * y_skew)
          end 

        end
        
        # 3
        if (seen[edge.key].length == 3)

          if (edge.line == seen[edge.key].keys[0])
            x_skew = -(x_skew)
            y_skew = -(y_skew)
            end

          if (edge.line == seen[edge.key].keys[1])
            x_skew = 0
            y_skew = 0
          end
          
          if (edge.line == seen[edge.key].keys[2])
            x_skew = (x_skew)
            y_skew = (y_skew)
          end

        end

      else
        
        x_skew = 0.0
        y_skew = 0.0

      end

      # change coords from OSGB to PNG/SVG
      map_ax = ( (edge.nax + x_skew - @x1.to_i) * x_factor )
      map_ay = @h.to_i - ( (edge.nay + y_skew - @y1.to_i) * y_factor )
	
      map_bx = ( (edge.nbx + x_skew - @x1.to_i) * x_factor )
      map_by = @h.to_i - ( (edge.nby + y_skew - @y1.to_i) * y_factor )

      svg << SVG::Line.new(map_ax, map_ay, map_bx, map_by) {
        self.style = SVG::Style.new
        self.style.stroke       = @@colours[edge.line.to_s]
        self.style.stroke_width = @@line_width
      }

    }
    cursor.close

    sql = "SELECT DISTINCT NVL(node_name, nods_name), 
                  nods_id,
                  node_osx,
                  node_osy
             FROM nodes,
                  nodesets
            WHERE node_nods_id = nods_id
              AND node_ntyp_id = 1
              AND node_osx >= :x1
              AND node_osx <= :x2
              AND node_osy >= :y1
              AND node_osy <= :y2"

    cursor = conn.parse(sql)
    cursor.bind_param(':x1', @x1.to_i, Fixnum)
    cursor.bind_param(':y1', @y1.to_i, Fixnum)
    cursor.bind_param(':x2', @x2.to_i, Fixnum)
    cursor.bind_param(':y2', @y2.to_i, Fixnum)
    cursor.exec
    
    cursor.fetch { |r| 
      node = SvgMapNode.new(r)
      
      map_x = ( (node.os_x - @x1.to_i) * x_factor )
      map_y = @h.to_i - ( (node.os_y - @y1.to_i) * y_factor )
      
      svg << SVG::Circle.new(map_x, map_y, 3) {
        self.style = SVG::Style.new
        self.style.stroke       = @@colours['black']
        self.style.fill         = @@colours['white']
        self.style.stroke_width = 2
      }
      
      svg << SVG::Text.new((map_x + 8), 
                           (map_y - 6),
                           # ick!
                           node.name.gsub(/&/, '&amp;')) {
        self.style = SVG::Style.new
        self.style.font         = 'sans-serif'
        self.style.stroke       = @@colours['black']
        self.style.font_size    = 10
        self.style.stroke_width = 0.1
      }
      
    }
    
    return svg.to_s

  end
  
end
  

class SvgMap
require 'svg/svg'

  def initialize(x1, y1, x2, y2)
    @x1, @y1 = x1, y1
    @x2, @y2 = x2, y2
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
                                           AND node_osx >= ?
                                           AND node_osx <= ?
                                           AND node_osy >= ?
                                           AND node_osy <= ? ) )
            ORDER BY l"
    
    conn = ActiveRecord::Base.connection
    cursor = conn.execute(sql, @x1, @x2, @y1, @y1)
    
    cursor.fetch do |r|
      
    end

    

  end
  
end

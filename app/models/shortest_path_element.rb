class ShortestPathElement

  attr_reader :name, :line_name, :direction
  attr_reader :nods_id, :node_id, :edge_id
  attr_reader :node_osx, :node_osy

  def initialize(r)
    @node_id     = r[0]
    @nods_id     = r[1]
    @name        = r[2]
    @line_name   = r[3]
    @edge_id     = r[4]
    @direction   = r[5]
    @node_osx    = r[6]
    @node_osy    = r[7]
  end

  def ShortestPathElement.new_by_node_id(id)
    node = Node.find(id)
    r = [ id, node.node_nods_id, node.node_name || node.nodeset.nods_name, nil, nil, nil, node.node_osx, node.node_osy ]
    return new(r)    
  end
end

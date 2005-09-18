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

end

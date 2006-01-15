require 'shortest_path_element'
require 'drb'

class ShortestPath

  attr_reader :path
  
  def initialize(start_nods_id, end_nods_id)
    @path     = Array.new
    @start_id = Nodeset.find(start_nods_id).nodes[0].node_id
    @end_id   = Nodeset.find(end_nods_id).nodes[0].node_id

    DRb.start_service()
    @map = DRbObject.new(nil, 'druby://localhost:9000')
  end
  
  def calc
    @map.shortest_path(@start_id, @end_id).each do |id|
      elem = ShortestPathElement.new_by_node_id(id)
      @path.push(elem)
    end
  end

end



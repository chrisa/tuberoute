require 'shortest_path_element'
class ShortestPath

  attr_reader :path
  
  def initialize(start_id, end_id)
    @path     = Array.new
    @start_id = start_id
    @end_id   = end_id
  end
  
  def calc
    dbh = ActiveRecord::Base.connection.connection
    plsql = dbh.parse("BEGIN dijkstra.nodeset_sssp(:start_id, :end_id, :cursor); END;")
    plsql.bind_param(':start_id', @start_id)
    plsql.bind_param(':end_id', @end_id)
    plsql.bind_param(':cursor', OCI8::Cursor)
    plsql.exec
    cursor = plsql[':cursor']
    
    cursor.fetch do |r|
      elem = ShortestPathElement.new(r)
      @path.push(elem)
    end
  end

end

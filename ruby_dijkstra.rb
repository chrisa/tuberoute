#!/usr/bin/ruby

require 'oci8'
require 'rubygems'
require_gem 'PriorityQueue'

class Node
  attr_reader :id, :name, :neighbours
  def initialize(id, name)
    @id = id
    @name = name
    @neighbours = Array.new
  end

  def add_neighbour(n)
    @neighbours.push(n)
  end
end

class Edge
  attr_reader :to
  def initialize(to, time, dist)
    @to, @time, @dist = to, time, dist
  end

  def weight
    @time + @dist
  end
end

class Map
  attr_reader :nodes
  def initialize 
    @nodes = Hash.new
  end

  def add_node(n)
    @nodes[n.id] = n
  end

  def add_node_neighbour(a, b)
    @nodes[a].add_neighbour(b)
  end
  
  def build_prev_hash(start, stop_at=nil)
    prev={start=>[nil, 0]} # hash to be returned
    return prev if stop_at==start
    # positions which we have seen, but we are not yet sure about
    # the shortest path to them (the value is length of the path,
    # for delete_min_value):
    active = CPriorityQueue.new
    active[start] = 0
    until active.empty?
      # get the position with the shortest path from the
      # active list
      cur = active.delete_min[0]
      return prev if cur == stop_at
      # for all reachable neighbors of cur, check if we found
      # a shorter path to them
      @nodes[cur].neighbours.each do |n|
        newlength = prev[cur][1]+n.weight # path to cur length + edge's weight
        if old = prev[n.to] # was n already visited
          # if we found a longer path, ignore it
          next if newlength>=old[1]
        end
        # (re)add new position to active list
        active[n.to] = newlength
        # set new prev and length
        prev[n.to] = [cur, newlength]
      end
    end
    prev
  end

  def shortest_path(from, to)
    prev=build_prev_hash(from, to)
    if prev[to]
      # path found, build it by following the prev hash from
      # "to" to "from"
      path=[to]
      path.unshift(to) while to=prev[to][0]
      path
    else
      nil
    end
  end
end

puts "%10.6f" % Time.now.to_f

map = Map.new
conn = OCI8.new 'map', 'map', 'MUNKYII'

# get all the node names and ids
cursor = conn.exec('SELECT node_id, 
                           nvl(node_name, nods_name)||\' \'||line_name
                      FROM nodes, 
                           nodesets,
                           node_lines,
                           lines
                     WHERE node_nods_id = nods_id
                       AND node_id = nodl_node_id
                       AND line_id = nodl_line_id')
cursor.fetch do |r|
  map.add_node Node.new(r[0], r[1])
end
cursor.close

# get all the edges and weights
cursor = conn.exec('SELECT edge_node_a_id,
                           edge_node_b_id,
                           (SELECT edgw_weight
                              FROM edge_weights
                             WHERE edgw_edge_id = edge_id
                               AND edgw_weig_id = 1
                               AND ROWNUM = 1) as time
                      FROM edges
                     WHERE edge_edgt_id = 1')
cursor.fetch do |r|
  map.add_node_neighbour r[0], Edge.new(r[1], r[2], 1)
end
cursor.close

# get all the edges within stations, weighted higher.
cursor = conn.exec('SELECT edge_node_a_id,
                           edge_node_b_id,
                           10 as time
                      FROM edges
                     WHERE edge_edgt_id = 2')
cursor.fetch do |r|
  map.add_node_neighbour r[0], Edge.new(r[1], r[2], 1)
end
cursor.close

conn.logoff

puts "%10.6f" % Time.now.to_f

to, from = ARGV[0..1].map { |id| id.to_i }
map.shortest_path(to, from).each do |id|
  puts map.nodes[id].name
end

puts "%10.6f" % Time.now.to_f

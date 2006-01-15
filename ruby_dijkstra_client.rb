#!/usr/bin/ruby

require 'drb'
DRb.start_service()
map = DRbObject.new(nil, 'druby://localhost:9000')

puts "%10.6f" % Time.now.to_f

to, from = ARGV[0..1].map { |id| id.to_i }
map.shortest_path(to, from).each do |id|
  puts id
end

puts "%10.6f" % Time.now.to_f

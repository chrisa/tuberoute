require 'oci8'
dbh = OCI8.new('map', 'map', 'munkyii.nodnol.org')

plsql = dbh.parse("BEGIN dijkstra.dijkstra(:start_id, :end_id, :cursor); END;")
plsql.bind_param(':start_id', ARGV[0])
plsql.bind_param(':end_id', ARGV[1])
plsql.bind_param(':cursor', OCI8::Cursor)
plsql.exec
cursor = plsql[':cursor']

cursor.fetch do |r|
  puts r.join(", ")
end




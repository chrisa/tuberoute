class Node < ActiveRecord::Base
    self.primary_key = "node_id"
    belongs_to :nodeset, :foreign_key => 'node_nods_id'
end

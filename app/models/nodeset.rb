class Nodeset < ActiveRecord::Base
    self.primary_key = "nods_id" 
    set_sequence_name "nods_id_seq"
    has_many :nodes, :foreign_key => 'node_nods_id'
end

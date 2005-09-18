class ShortestPathController < ApplicationController

  def path
    @p = ShortestPath.new(params[:start_id], params[:end_id])
    @p.calc
    
    @start_id = params[:start_id]
    @end_id   = params[:end_id]
  end

  def list
    @nodesets = Nodeset.find(:all, :conditions => [ 'LOWER(nods_name) LIKE ? ORDER BY nods_name', @params['search'].downcase + '%' ],
                                   :limit => 20)
    @id_name = params[:id_name]
    render_without_layout
  end

end

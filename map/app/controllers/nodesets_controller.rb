class NodesetsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @nodeset_pages, @nodesets = paginate :nodeset, :per_page => 10
  end

  def show
    @nodeset = Nodeset.find(params[:id])
  end

  def new
    @nodeset = Nodeset.new
  end

  def create
    @nodeset = Nodeset.new(params[:nodeset])
    if @nodeset.save
      flash[:notice] = 'Nodeset was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @nodeset = Nodeset.find(params[:id])
  end

  def update
    @nodeset = Nodeset.find(params[:id])
    if @nodeset.update_attributes(params[:nodeset])
      flash[:notice] = 'Nodeset was successfully updated.'
      redirect_to :action => 'show', :id => @nodeset
    else
      render :action => 'edit'
    end
  end

  def destroy
    Nodeset.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end

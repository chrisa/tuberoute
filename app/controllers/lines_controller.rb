class LinesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @line_pages, @lines = paginate :line, :per_page => 10
  end

  def show
    @line = Line.find(params[:id])
  end

  def new
    @line = Line.new
  end

  def create
    @line = Line.new(params[:line])
    if @line.save
      flash[:notice] = 'Line was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @line = Line.find(params[:id])
  end

  def update
    @line = Line.find(params[:id])
    if @line.update_attributes(params[:line])
      flash[:notice] = 'Line was successfully updated.'
      redirect_to :action => 'show', :id => @line
    else
      render :action => 'edit'
    end
  end

  def destroy
    Line.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end

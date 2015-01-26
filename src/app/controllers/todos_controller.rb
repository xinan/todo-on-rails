class TodosController < ApplicationController

  def index
    @todos = Todo
    @todo = Todo.new
    if request.xhr?
      respond_to do |format|
        format.html { render :partial => 'list', :locals => {:todos => @todos} }
      end
    end
  end

  def tags
    @tags = ActsAsTaggableOn::Tag.all
    respond_to do |format|
      format.html { render :partial => 'list', :locals => {:todos => Todo.tagged_with('tags')} }
      format.json { render json: @tags }
    end
  end

  def show
    @todos = Todo.tagged_with(params[:id])
    respond_to do |format|
      format.html { render :partial => 'list', :locals => {:todos => @todos} }
      # format.json { render json: @todos, status: :ok, location: @todos }
    end
  end

  def create
    @todo = Todo.new(todo_params)
    @todo.completed = false

    respond_to do |format|
      if @todo.save
        format.html { render :partial => 'todo', :locals => {:todo => @todo} }
        # format.json { render json: @todo, status: :created, location: @todo }
      else
        format.json { head :no_content }
      end
    end
  end

  def update
    @todo = Todo.find(params[:id])
    @todo.update(todo_params)
    respond_to do |format|
      format.json { respond_with_bip(@todo) }
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  def todo_params
    params.require(:todo).permit(:title, :completed, :tag_list)
  end
end

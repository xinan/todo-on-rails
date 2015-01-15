class AddTitleCompletedToTodo < ActiveRecord::Migration
  def change
    add_column :todos, :title, :string
    add_column :todos, :completed, :boolean
  end
end

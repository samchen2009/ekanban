class AddDescriptionToKanbanState < ActiveRecord::Migration
  def change
  	#table "user"
  	add_column :kanban_states, :description, :text, :limit => 128
  end
end
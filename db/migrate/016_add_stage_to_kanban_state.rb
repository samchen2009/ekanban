class AddStageToKanbanState < ActiveRecord::Migration
  def change
  	#table "user"
  	add_column :kanban_states, :stage_id, :integer, :default=>0
  end
end
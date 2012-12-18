class AddKanbanIdToWorkflow < ActiveRecord::Migration
  def change
  	#table "user"
  	add_column :kanban_workflows, :kanban_id, :integer, :default=>0
  end
end
class AddRoleColToKanbanPane < ActiveRecord::Migration
	def change
  		add_column :kanban_panes, :role_id, :integer, :default => 1, :null => false
  	end
 end
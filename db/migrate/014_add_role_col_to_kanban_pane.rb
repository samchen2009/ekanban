class AddRoleColToKanbanPane < ActiveRecord::Migration
	def change
  		change_column :kanban_panes, :wip_limit, :integer, :default => 1, :null => false
  	end
 end
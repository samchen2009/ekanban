class AddInProgressColToKanbanPane < ActiveRecord::Migration
	def change
  		add_column :kanban_panes, :in_progress, :boolean, :default => true, :null => false
  	end
 end
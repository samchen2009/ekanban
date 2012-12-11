class RenameKanbanCardCol < ActiveRecord::Migration
	def change
		rename_column :kanban_cards, :tester_id, :verifier_id
  	end
 end


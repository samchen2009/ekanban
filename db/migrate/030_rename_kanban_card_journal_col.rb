class RenameKanbanCardJournalCol < ActiveRecord::Migration
	def change
		rename_column :kanban_card_journals, :card_id, :kanban_card_id
		rename_column :kanban_card_journals, :created_on, :created_at
  	end
 end
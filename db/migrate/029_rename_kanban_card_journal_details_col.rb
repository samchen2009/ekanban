class RenameKanbanCardJournalDetailsCol < ActiveRecord::Migration
	def change
		rename_column :kanban_card_journal_details, :prop_keys, :prop_key
  	end
 end
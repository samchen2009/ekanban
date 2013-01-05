class CreateKanbanCardJournalDetails < ActiveRecord::Migration
  def change
    create_table :kanban_card_journal_details do |t|
      t.integer :journal_id
      t.string  :prop_keys
      t.integer :old_value
      t.integer :new_value
    end
  end
end
class CreateKanbanCardJournals < ActiveRecord::Migration
  def change
    create_table :kanban_card_journals do |t|
      t.integer :card_id
      t.integer :issue_journal_id
      t.datetime :created_on
    end
  end
end
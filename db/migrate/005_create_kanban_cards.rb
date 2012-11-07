class CreateKanbanCards < ActiveRecord::Migration
  def change
    create_table :kanban_cards do |t|
      t.integer :issue_id
      t.integer :developer_id
      t.integer :tester_id
    end
  end
end

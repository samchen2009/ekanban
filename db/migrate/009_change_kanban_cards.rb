class ChangeKanbanCards < ActiveRecord::Migration
  def change
    change_table :kanban_cards do |t|
      t.integer :kanban_pane_id
    end
  end
end

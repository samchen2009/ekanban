class ChangeKanbanCards < ActiveRecord::Migration
  def self.up
    change_table :kanban_cards do |t|
      t.integer :kanban_pane_id
    end
  end
  
  def self.down
    change_table :kanban_cards do |t|
      t.remove :kanban_pane_id
    end
  end
end

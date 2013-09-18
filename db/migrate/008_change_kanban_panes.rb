class ChangeKanbanPanes < ActiveRecord::Migration
  def self.up
    change_table :kanban_panes do |t|
      t.integer :kanban_state_id
      t.remove :is_user_wip
      t.boolean :wip_limit_auto
    end
  end
  
  def self.down
    change_table :kanban_panes do |t|
      t.remove :kanban_state_id
      t.integer :is_user_wip
      t.remove :wip_limit_auto
    end
  end
end

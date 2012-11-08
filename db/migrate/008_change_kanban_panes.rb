class ChangeKanbanPanes < ActiveRecord::Migration
  def change
    change_table :kanban_panes do |t|
      t.integer :kanban_state_id
      t.remove :is_user_wip
      t.boolean :wip_limit_auto
    end
  end
end

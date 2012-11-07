class CreateKanbanPanes < ActiveRecord::Migration
  def change
    create_table :kanban_panes do |t|
      t.string :name
      t.integer :kanban_id
      t.integer :wip_limit
      t.integer :is_user_wip
    end
  end
end

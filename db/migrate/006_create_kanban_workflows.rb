class CreateKanbanWorkflows < ActiveRecord::Migration
  def change
    create_table :kanban_workflows do |t|
      t.integer :old_state_id
      t.integer :new_state_id
      t.boolean :check_role
      t.integer :check_wip_limit
      t.integer :role_id
    end
  end
end

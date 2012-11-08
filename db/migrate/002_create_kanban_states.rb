class CreateKanbanStates < ActiveRecord::Migration
  def change
    create_table :kanban_states do |t|
      t.string :name
      t.boolean :is_default
      t.boolean :is_initial
      t.boolean :is_closed
      t.integer :tracker_id
      t.integer :position
    end
  end
end

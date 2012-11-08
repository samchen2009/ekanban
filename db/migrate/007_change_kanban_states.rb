class ChangeKanbanStates < ActiveRecord::Migration
  def change
    change_table :kanban_states do |t|
      t.integer :position
    end
  end
end

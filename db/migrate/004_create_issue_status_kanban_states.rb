class CreateIssueStatusKanbanStates < ActiveRecord::Migration
  def change
    create_table :issue_status_kanban_states do |t|
      t.integer :issue_status_id
      t.integer :kanban_state_id
    end
  end
end

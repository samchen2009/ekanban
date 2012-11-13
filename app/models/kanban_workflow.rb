class KanbanWorkflow < ActiveRecord::Base
  unloadable
  belongs_to :old_state, :class_name => "KanbanState"
  belongs_to :new_state, :class_name => "KanbanState"
  belongs_to :role

  scope :possible_transition, lambda {|current_state|
    {:conditions => ["#{KanbanWorkflow.table_name}.old_state_id = ?", current_state]}
  }

end

class KanbanWorkflow < ActiveRecord::Base
  unloadable
  belongs_to :old_state, :class_name => "KanbanState"
  belongs_to :new_state, :class_name => "KanbanState"
  belongs_to :role
end

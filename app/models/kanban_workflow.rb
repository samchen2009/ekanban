class KanbanWorkflow < ActiveRecord::Base
  unloadable
  belongs_to :old_state, :class_name => "KanbanState"
  belongs_to :new_state, :class_name => "KanbanState"
  belongs_to :role

  scope :possible_transition, lambda {|current_state,kanban_id|
    {:conditions => ["#{KanbanWorkflow.table_name}.old_state_id = ? and kanban_id = ?", current_state,kanban_id]}
  }

  def self.transition_allowed?(current,expect,kanban_id)
    return true if KanbanState.to_id(current) == KanbanState.to_id(expect)
  	transition = KanbanWorkflow.where("old_state_id=? and new_state_id=? and kanban_id=?",KanbanState.to_id(current),KanbanState.to_id(expect),kanban_id)
  	return !transition.empty?
  end

end

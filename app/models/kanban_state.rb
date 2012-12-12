class KanbanState < ActiveRecord::Base
  unloadable
  belongs_to :tracker
  belongs_to :kanban_stage,  :foreign_key => :stage_id

  scope :by_tracker, lambda {|tracker|
  	tracker_id = tracker.nil? ? 0 : tracker.is_a?(Tracker) ? tracker.id : tracker.to_i
    {:conditions => ["#{KanbanWorkflow.table_name}.old_state_id = ?", current_state]}
  }

  def self.to_id(state)
    state_id = state.nil? ? nil : state.is_a?(KanbanState) ? state.id : state.to_i
  end

  def self.to_state(state)
    state = state.nil? ? nil : state.is_a?(KanbanState) ? state : KanbanState.find(state)
  end

  def self.in_same_stage?(*states)
  	stage = KanbanState.to_state(states[0]).stage_id
  	states.each {|s| return false if stage != KanbanState.to_state(s).stage_id}
  	return true
  end

end

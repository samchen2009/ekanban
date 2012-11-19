class KanbanState < ActiveRecord::Base
  unloadable
  belongs_to :tracker
  belongs_to :kanban_stage,  :foreign_key => :stage_id

  scope :by_tracker, lambda {|tracker|
  	tracker_id = tracker.nil? ? 0 : tracker.is_a?(Tracker) ? tracker.id : tracker.to_i
    {:conditions => ["#{KanbanWorkflow.table_name}.old_state_id = ?", current_state]}
  }
end

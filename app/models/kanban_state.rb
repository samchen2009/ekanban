class KanbanState < ActiveRecord::Base
  unloadable
  belongs_to :tracker

  scope :by_tracker, lambda {|tracker|
  	tracker_id = tracker.nil? ? 
    {:conditions => ["#{KanbanWorkflow.table_name}.old_state_id = ?", current_state]}
  }
end

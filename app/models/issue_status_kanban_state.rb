class IssueStatusKanbanState < ActiveRecord::Base
  unloadable

  belongs_to  :kanban_state
  belongs_to  :issue_status
  
end

class KanbanCard < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :developer, :class_name => :User
  belongs_to :tester,  :class_name => :User
  belongs_to :kanban_pane, :class_name => :KanbanPane

end

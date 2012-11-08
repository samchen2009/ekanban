class Kanban < ActiveRecord::Base
  unloadable
  
  belongs_to  :project
  belongs_to  :tracker
  has_many  :kanban_pane

end

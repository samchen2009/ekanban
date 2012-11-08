class KanbanPane < ActiveRecord::Base
  unloadable

  belongs_to  :kanban_state
  belongs_to  :kanban 
  has_many    :kanban_card
end

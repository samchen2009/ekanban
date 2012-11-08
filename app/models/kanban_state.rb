class KanbanState < ActiveRecord::Base
  unloadable
  belongs_to :tracker
end

class KanbanStage < ActiveRecord::Base
  unloadable

  before_destroy :check_kanban_states

  def check_kanban_states
  	count = KanbanState.count(:all, :conditions => ["stage_id = ?",self.id])
  	if count > 0
  		errors.add("","Cannot delete stage #{self.name} as #{count} state still use it")
  	end
  	errors.blank?
  end
end

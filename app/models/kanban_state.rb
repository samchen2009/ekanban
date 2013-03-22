class KanbanState < ActiveRecord::Base
  unloadable
  belongs_to :tracker
  belongs_to :kanban_stage,  :foreign_key => :stage_id
  has_many  :kanban_pane
  has_many  :issue_status_kanban_state
  has_many :issue_status, :through => :issue_status_kanban_state
  validates_presence_of :tracker
  validates_presence_of :kanban_stage
  before_destroy :check_panes_and_issue_status

  def check_panes_and_issue_status
    count = KanbanPane.count(:all, :joins => :kanban, :conditions => ["#{Kanban.table_name}.is_valid = ? and kanban_state_id = ?",true, self.id])
    if count > 0
      errors.add("","Cannot delete state #{self.name}, #{count} panes still use it!")
    end

    count = IssueStatusKanbanState.count(:all, :conditions => ["kanban_state_id = ?",self.id])
    if count > 0
      errors.add("","Cannot delete state #{self.name}, #{count} issue status associated with it")
    end
    errors.blank?
  end

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

  def self.close_state(kanban)
    return nil if kanban.nil?
    pane = kanban.kanban_pane.detect {|p| p.kanban_state.is_closed == true}
    pane.nil? ? nil: pane.kanban_state
  end

end

class KanbanCard < ActiveRecord::Base 
  unloadable
  belongs_to :issue
  belongs_to :developer, :class_name => :User
  belongs_to :verifier,  :class_name => :User
  belongs_to :kanban_pane, :class_name => :KanbanPane
  has_many :issue_journals, :through => "issue"
  has_many :kanban_card_journals

  scope :by_group, lambda {|group|
    return if group.nil?
    if (group.is_a?(User))
      group_id = User.to_id(group)
    else
      group_id = Group.to_id(group)
    end
    {:conditions => ["#{Issue.table_name}.assigned_to_id = ? or #{Issue.table_name}.assigned_to_id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id,group_id], :include => :issue}
  }

  scope :in_pane, lambda {|pane|
    pane_id = KanbanPane.to_id(pane)
    {:conditions => ["kanban_pane_id=?", pane_id]}
  }

  scope :by_user, lambda {|user|
    user_id = User.to_id(user)
    {:conditions => ["#{Issue.table_name}.assigned_to_id=?", user_id], :include => :issue}
  }

  scope :by_member, lambda {|member|
    user_id = member.nil? ? User.current.id :  member.is_a?(Member) ? member.user_id : member.to_i
    {:conditions => ["#{Issue.table_name}.assigned_to_id=?", user_id], :include => :issue}
  }

  scope :by_project_tracker, lambda {|project,tracker|
  	project_id = project.nil? ? Project.current : project.is_a?(Project) ? project.id : project.to_i
  	tracker_id = tracker.nil? ? Project.all.first.tracker.id : tracker.is_a?(Tracker) ? tracker.id : tracker.to_i
  	{:conditions => ["#{Issue.table_name}.project_id=? #{Issue.table_name}.tracker_id=?",project_id,tracker_id], :include => [:issue]}
  }

  scope :by_state, lambda {|state|
  	return nil if state.nil?
  	status_id = IssueStatusKanbanState.status_id(state)
  	return nil if status_id.nil?
    {:conditions => ["#{Issue.table_name}.status_id = ?", status_id], :include => :issue}
  }

  scope :in_progress, lambda {
    {:conditions => ["#{KanbanPane.table_name}.in_progress = ?", true], :include => :kanban_pane}
  }

  scope :open, lambda {|*args|
    is_closed = args.size > 0 ? !args.first : false
    is_closed_id = IssueStatus.closed_id; 
    {:conditions => ["#{Issue.table_name}.status_id #{is_closed ? "" : "!"}= ?", is_closed_id], :include => [:issue]}
  }

  def in_progress?(roles)
    pane = self.kanban_pane
    role = Role.find(pane.role_id)
    # card in a non-in-progress pane or card 
    return false if !pane.in_progress
    true
  end

end


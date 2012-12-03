class KanbanCard < ActiveRecord::Base 
  unloadable
  belongs_to :issue
  belongs_to :developer, :class_name => :User
  belongs_to :tester,  :class_name => :User
  belongs_to :kanban_pane, :class_name => :KanbanPane

  scope :by_group, lambda {|group|
    return if group.nil?
    if (group.is_a?(User))
      group_id = User.to_id(group)
    else
      group_id = Group.to_id(group)
    end
    {:conditions => ["#{Issue.table_name}.assigned_to_id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id], :include => :issue}
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
    {:conditions => ["#{Issue.table_name}.status_id = ?", status_id], :include => [:issue]}
  }

  scope :open, lambda {|*args|
    is_closed = args.size > 0 ? !args.first : false
    is_closed_id = IssueStatus.closed_id; 
    {:conditions => ["#{Issue.table_name}.status_id #{is_closed ? "" : "!"}= ?", is_closed_id], :include => [:issue]}
  }

end

class Issue < ActiveRecord::Base

  scope :belong_to_group, lambda {|group|
    group_id = group.nil? ? User.current_group : group.is_a?(Group) ? group.id : group.to_i
    {:conditions => ["#{Issue.table_name}.assigned_to_id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id]}
  }

  scope :belong_to_user, lambda {|user|
    user_id = user.nil? ? User.current :  user.is_a?(User) ? user.id : user.to_i
    {:conditions => ["#{Issue.table_name}.assigned_to_id=?", user_id]}
  }

  #usage
  #Issue.belong_to(user) => all issues belong to user
  #Issue.belong_to(group) => all issues belong to group
  #Issue.belong_to() => all issues belong to current project
  #Issue.belong_to(user,project) => project issue belong to user
  #Issue.belong_to(group,project) => project issue belong to group
  scope :belong_to, lambda {|*args|

  	project_id = user_id = group_id = nil
  	args.to_a.each do |arg|
  		user_id = arg.id if arg.is_a?(User)
  		project_id = arg.id if arg.is_a?(Project)
  		group_id = arg.id if arg.is_a?(Group)
  	end

  	conditions = []
  	values = []
  	if user_id
  		conditions << "#{Issue.table_name}.assigned_to_id=?"
  		values << user_id
  	end
  	if group_id
  		conditions << "#{Issue.table_name}.assigned_to_id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)"
  		values << group_id
  	end
  	if project_id
  		conditions << "#{Issue.table_name}.project_id=?"
  		values << project_id
  	end
  	{:conditions => conditions.join(' and ').to_a.concat(values)}
  }


end

class IssueStatus < ActiveRecord::Base
  def self.closed_id
  	#IssueStatus.all.each {|x| return x.id if x.is_closed} 
    status = IssueStatus.where(:is_closed => 1)
    return status.id if status.nil?
  end
end

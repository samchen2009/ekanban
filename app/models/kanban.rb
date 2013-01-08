class Kanban < ActiveRecord::Base
  unloadable
  
  belongs_to  :project
  belongs_to  :tracker
  belongs_to  :creater, :foreign_key => :created_by, :class_name => :User
  has_many  :kanban_pane, :order => "position ASC"
  validates_presence_of  :project_id, :tracker_id

  before_destroy :delete_all_members

  #scope :by_project_tracker, lambda{ |project,tracker| {:conditions => ["#{Kanban.table_name}.project_id = #{project} and #{Kanban.table_name}.tracker_id = #{tracker_id}"]}}
  scope :by_project, lambda {|project| 
  	project_id = project.nil? ? Project.current : project.is_a?(Project) ? project.id : project.to_i
  	where(:project_id => project_id)
  }
  scope :by_tracker, lambda {|tracker| where(:tracker_id => tracker)}
  scope :valid, lambda {where(:is_valid => true)}

  def self.to_id(kanban)
    kanban_id = kanban.nil? ? nil : kanban.is_a?(Kanban) ? kanban.id : kanban.to_i
  end

  def self.to_kanban(kanban)
    kanban = kanban.nil? ? nil : kanban.is_a?(kanban) ? kanban : kanban.find(kanban)
  end
end


class Group < Principal
  def self.to_id(group)
    group_id = group.nil? ? nil : group.is_a?(Group) ? group.id : group.to_i
  end

  def self.to_group(group)
    group = group.nil? ? nil : group.is_a?(Group) ? group : Group.find(group)
  end

  def wip_limit(role=nil, project=nil)

    if role.nil? or project.nil?
      users = User.in_group(self)
    else
      project = Project.to_project(project)
      role = Role.to_role(role)
      users = User.member_of(project).in_group(self)
      users.select!{|u| u.roles_for_project(project).include?(role)}
    end

    wip_limit = users.inject(0) {|sum,user| sum + user.wip_limit}
  end
end

class Project < ActiveRecord::Base
  has_many :kanban
  def self.to_id(project)
    project_id = project.nil? ? nil : project.is_a?(Project) ? project.id : project.to_i
  end

  def self.to_project(project)
    project = project.nil? ? nil : project.is_a?(Project) ? project : Project.find(project)
  end

  #the sum of all member(with specific role) wip limit.
  def wip_limit(role)
    role = Role.to_role(role)
    wip_limit = self.members.inject(0) do |sum,member|
      user = member.user
      (user.roles_for_project(self).include?(role) or role.nil?) ? (sum + user.wip_limit) : sum
    end
  end
end

class Role < ActiveRecord::Base
  def self.to_id(role)
    role_id = role.nil? ? nil : role.is_a?(Role) ? role.id : role.to_i
  end

  def self.to_role(role)
    role = role.nil? ? nil : role.is_a?(Role) ? role : (role.to_i == 0) ? Role.find_by_name(role) : Role.find(role)
  end

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

  validate :validate_kanban_card_update, :if => Proc.new{!self.new_record?}
  validate :validate_kanban_card_new, :if => Proc.new{self.new_record?}
  validates_presence_of :assigned_to

  def validate_kanban_card_new
    issue = self
    kanban = Kanban.find_by_project_id_and_tracker_id(issue.project_id,issue.tracker_id)
    return true if kanban.nil?

    state_id = IssueStatusKanbanState.state_id(issue.status_id, issue.tracker_id)
    if (state_id.nil?)
      errors.add(:status_id, ":No kanban state associated with status '#{issue.issue_status.name}', contact redmine admin!")
      return false
    end
    pane = KanbanPane.pane_by(state_id, kanban);
    if pane.nil?
      errors.add(:status_id, ":No kanban pane associated with status '#{issue.issue_status.name}', contact redmine admin!")
      return false
    end

    old_state = KanbanState.find_by_tracker_id_and_is_initial(issue.tracker_id,true)
    if (old_state.nil?)
      errors.add(:status_id, ":No kanban state associated with status 'new', contact redmine admin!")
      return false
    end

    errors.add(:status_id, ":Cannot move from '#{old_state.name}' to '#{pane.name}'") if !KanbanWorkflow.transition_allowed?(old_state.id,state_id,kanban.id)

    #issue status change? - need to check pane's wip and wip limit
    if pane.wip_limit_by_view() <= KanbanPane.wip(pane)
      errors.add :assigned_to_id, ":No resource left in Pane #{new_pane.name}, increase their wip_limit) or add new resources!}"
    end

    assignee = issue.assigned_to
    if assignee.wip >= assignee.wip_limit  and  pane.in_progress == true
      errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, who is overloading now! Change assignee or increase his/her wip_limit"
    end

    #need to check the role (both user's and pane's)
    if !pane.accept_user?(assignee)
      errors.add :assigned_to_id, ":Pane #{new_pane.name} doesn't accept #{assignee.alias}, check his/her roles!"
    end
    puts errors if errors.full_messages.any?
  end

  def validate_kanban_card_update
    # Validate
      # 1. user's wip and permission(role).
      # 2. corresponding pane.
      # 3. ...
    issue = self
    card = KanbanCard.find_by_issue_id(issue.id)
    assignee = issue.assigned_to
    kanban = Kanban.find_by_project_id_and_tracker_id(issue.project_id,issue.tracker_id)
    #only apply to issue with kanban created.
    return true if kanban.nil?

    new_state = IssueStatusKanbanState.state_id(issue.status_id, issue.tracker_id)
    new_pane = KanbanPane.pane_by(new_state,kanban)
    errors[:status_id] = ":No Kanban Pane associated with Kanban State!" if new_pane.nil?

    # Tracker changed.
    if kanban.id != card.kanban_pane.kanban.id
        old_state = new_state
        old_pane  = new_pane
    else
        old_state = card.kanban_pane.kanban_state_id
        old_pane  = card.kanban_pane
    end
    errors.add(:status_id, ":Cannot move from '#{old_pane.name}' to '#{new_pane.name}'") if !KanbanWorkflow.transition_allowed?(old_state,new_state,kanban.id)

    #assignee changed?
    if @attributes_before_change
      before = @attributes_before_change["assigned_to_id"]
      after = issue.assigned_to_id
      if before != after and assignee.wip >= assignee.wip_limit and new_pane.in_progress == true
        errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, who is overloading now! Change owner or increase its wip_limit"
      end
    end

    #issue status change? - need to check pane's wip and wip limit
    if !KanbanState.in_same_stage?(old_state, new_state)
      if new_pane.wip_limit_by_view() <= KanbanPane.wip(new_pane)
        errors.add :status_id, ":Cannot set kanban state to #{new_pane.name}, no resource left, increase their wip_limit or add new resources}"

      end

      if assignee.wip >= assignee.wip_limit  and  new_pane.in_progress == true
        errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, who is overloading now! Change owner or increase its wip_limit"
      end
    end

    #need to check the role (both user's and pane's)
    if !new_pane.accept_user?(assignee)
      errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, Pane #{new_pane.name} doesn't accept him/her, check his roles and wip_limit!"
    end
    puts errors if errors.full_messages.any?

    #TODO: validate present of start_date and due_date if status is "accepted"
  end
end

class User < Principal
  def self.to_id(user)
    user_id = user.nil? ? User.current : user.is_a?(User) ? user.id : user.to_i
  end

  def self.to_user(user)
    user = user.nil? ? User.current : user.is_a?(User) ?  user : User.find(user)
  end

  def has_role?(role,project)
    role = Role.to_role(role)
    return true if (role.name == "Anonymous" or role.name == "Non member") 
    return self.roles_for_project(Project.to_project(project)).include?(role)
  end

  def wip
    KanbanCard.open().by_user(self).in_progress().size
  end

  def wip_limit
    id = CustomField.find_by_name("WIP limit").id
    v = self.custom_value_for(id)
    v.nil? ? 3 : v.value.to_i
  end

end

class Principal < ActiveRecord::Base
  def alias
    return self.login if self.login != ""
    return self.firstname + " " + self.lastname
  end
end

class IssueStatus < ActiveRecord::Base
  def self.closed_id
    #IssueStatus.all.each {|x| return x.id if x.is_closed} 
    status = IssueStatus.where("is_closed = ?", true)
    return status.first.id if !status.nil?
  end
end

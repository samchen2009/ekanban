class KanbanPane < ActiveRecord::Base
  unloadable

  belongs_to  :kanban_state
  belongs_to  :kanban
  has_many    :kanban_card
  has_many    :issue, :through=>:kanban_card, :order => "priority_id ASC, updated_on DESC, issue_id DESC"

  PROJECT_VIEW = 0
  GROUP_VIEW = 1
  USER_VIEW = 2

  attr_accessor :view

  scope :by_kanban, lambda {|kanban| 
    kanban_id = Kanban.to_id(kanban)
    where(:kanban_id => kanban_id)
  }

  def initialize
  	@view = PROJECT_VIEW  #"project"/"group"/"user"
  end

  def open_cards()
  	is_closed_id = IssueStatus.closed_id;
  	self.kanban_card.reject{|card| card.issue.status_id == is_closed_id}
  end

  def closed_cards()
    is_closed_id = IssueStatus.closed_id;
    self.kanban_card.reject{|card| card.issue.status_id != is_closed_id}
  end

  # Get Pane's or User's WIP limit, don't naming the function as wip_limit
  def wip_limit_by_view(project, group=nil, user=nil)
    if self.wip_limit_auto == false
      return self.wip_limit
    end

    if (group.nil? and user.nil?)
      @view = PROJECT_VIEW
      project = Project.to_project(project)
      project = self.kanban.project if project.nil?
      puts "project  = #{project}"
      wip_limit = project.wip_limit(self.role_id)
    elsif !user.nil?
      @view = USER_VIEW
      user = User.to_user(user)
      return user.wip_limit
    else
      @view = GROUP_VIEW
      group = Group.to_group(group)
      return group.wip_limit(self.role_id, project);
    end
  end

  # Get Pane's or Group's WIP
  def wip(arg=nil)
    if @view == PROJECT_VIEW
      #members in this project and role matches this pane
      #for example, design/coding panes only count developer's wip.
      return self.open_cards().size || 0
    elsif @view == GROUP_VIEW
      group = Group.to_group(arg)
      return 0 if group.nil?
      return 0 || self.open_cards().select{|card| group.users.collect{|u| u.id}.include?(card.issue.assigned_to_id)}.size
    elsif @view == USER_VIEW
      user_id = User.to_id(arg)
      return 0 if user_id.nil?
      return 0 || self.open_cards().select{|card| card.issue.assigned_to_id == user_id}.size
    else
      return 0
    end
  end

  def accept_user?(user)
    user = User.to_user(user)
    project = self.kanban.project
    #check whether a project member first.
    puts "check whether user is member of project #{project.name}"
    return false if user.member_of?(project)

    #check whether user still have capacity
    puts "check whether user reach wip_limit(#{user.wip_limit})"
    return false if user.wip_limit <= self.wip(user)

    #check whether the role in this pane.
    puts "check whether user's role is allowed in this pane"
    #roles = user.roles_for_project(project)
    #return false if roles.nil?
    #roles.each {|role| return true if role.id == self.role_id}
    return true
  end
end

class User < Principal
  def self.to_id(user)
    user_id = user.nil? ? User.current : user.is_a?(User) ? user.id : user.to_i
  end

  def self.to_user(user)
    user = user.nil? ? User.current : user.is_a?(User) ?  user : User.find(user)
  end
end

class Group < Principal
  def self.to_id(group)
    group_id = group.nil? ? nil : group.is_a?(Group) ? group.id : group.to_i
  end

  def self.to_group(group)
    group = group.nil? ? nil : group.is_a?(Group) ? group : Group.find(group)
  end

  def wip_limit(role=nil,project=nil)
    project = Project.to_project(project)
    role = Role.to_role(role)
    users = User.member_of(project).in_group(self)

    wip_limit = users.inject(0) {|sum,user|
      (user.roles_for_project(project).include?(role) or role.nil?) ? (sum+user.wip_limit) : sum
    }
    wip_limit
  end
end

class Project < ActiveRecord::Base
  def self.to_id(project)
    project_id = project.nil? ? nil : project.is_a?(Project) ? project.id : project.to_i
  end

  def self.to_project(project)
    project = project.nil? ? nil : project.is_a?(Project) ? project : Project.find(project)
  end

  def wip_limit(role=nil)
    role = Role.to_role(role)
    wip_limit = self.members.inject(0) do |sum,member|
      user = member.user
      (user.roles_for_project(self).include?(role) or role.nil?) ? (sum + user.wip_limit) : sum
    end
    wip_limit
  end
end

class Role < ActiveRecord::Base
  def self.to_id(role)
    role_id = role.nil? ? nil : role.is_a?(Role) ? role.id : role.to_i
  end

  def self.to_role(role)
    role = role.nil? ? nil : role.is_a?(Role) ? role : Role.find(role)
  end
end
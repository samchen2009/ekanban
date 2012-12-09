class Kanban < ActiveRecord::Base
  unloadable
  
  belongs_to  :project
  belongs_to  :tracker
  has_many  :kanban_pane

  validates_presence_of  :project_id, :tracker_id, :is_valid

  after_save :update_position_under_parent, :if => Proc.new {|project| project.name_changed?}
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
    role = role.nil? ? nil : role.is_a?(Role) ? role : Role.find(role)
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
end

class User < Principal
  def self.to_id(user)
    user_id = user.nil? ? User.current : user.is_a?(User) ? user.id : user.to_i
  end

  def self.to_user(user)
    user = user.nil? ? User.current : user.is_a?(User) ?  user : User.find(user)
  end
end

class IssueStatus < ActiveRecord::Base
  def self.closed_id
    #IssueStatus.all.each {|x| return x.id if x.is_closed} 
    status = IssueStatus.where("is_closed = 't'")
    return status.first.id if !status.nil?
  end
end

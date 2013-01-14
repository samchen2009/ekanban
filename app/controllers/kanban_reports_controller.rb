class KanbanReportsController < ApplicationController

	def users(group=nil,project=nil)
		#get the users in a group according to project.
		debugger
		group = (group == nil? || group == "0") ? nil : Group.to_group(group)
		project = (project == nil? || project == "0") ? nil : Project.to_project(project)
		users = group.nil? ? User.find(:all, :conditions => ["lastname != 'Admin' and lastname !='Anonymous'"]) : group.users.sort
		if project
			users.reject! {|u| !u.member_of?(project)}
		end
		users
	end

	def index
		puts params
		@groups = Group.all
		@projects = Project.find_all_by_is_public_and_status(true,1)
		@kanbans =  Kanban.find_all_by_is_valid(true)
		@members = User.all
		@wip_statuses = statuses("In Progress")
		@planed_statuses = statuses("Planed")
		@test_statuses = statuses("Test")
		@release_statuses = statuses("Release")
		@closed_statuses = statuses("Closed")
	end

	def columns()
		return ["name", "group", "total", "wip", "wip_limit", "loading",
			"planed","testing"
		]
	end

	def td_link_and_text(user,column)
		case column
		when "total"
			return total_issues(user);
		when "wip"
			return {:count => user.wip, :params=>wip_issues_params(user)}
		when "wip_limit"
			return {:count => user.wip_limit, :params => edit_user_path(user.id)}
		when "loading"
			return {:count => user.wip * 100 / user.wip_limit,:params => nil}
		when "planed"
			return issues_count_and_link(user,@planed_statuses)
		when "test"
			return issues_count_and_link(user,@test_statuses)
		end
 	end

 	def issues_count_and_link(principal,statuses)
 		if principal.nil?
 			conditions = ["assigned_to_id=? ",principal.id]
 		else
 			conditions = ["assigned_to_id != 0"]
 		end
		statuses.each_with_index do |x,i|
			rp = (i == 0) ? "and" : "or"
			conditions[0] += " #{rp} " + "status_id = ?"
			conditions << x
		end
		count = Issue.count(:conditions => conditions)
		params = {:set_filter => "1",:f => [:status_id,:assigned_to_id],
			:op => {:status_id => "=", :assigned_to_id => "="},
			:v => {:assigned_to_id => ["#{principal.id}"], :status_id => statuses}}
		return  {:count => count, :params => params}
 	end

	def total_issues(principal)
		count = Issue.open.count(:conditions => "assigned_to_id=#{principal.id}")
		if principal.nil?
			params = {:set_filter => "1",:f => [:status_id],
			:op => {:status_id => 'o'}}
		else
			params = {:set_filter => "1",:f => [:status_id, :assigned_to_id],
			:op => {:status_id => 'o', :assigned_to_id => "="},
			:v => {:assigned_to_id => ["#{principal.id}"]}}
		end
		return {:count => count, :params => params}
	end

	def statuses(stage_name)
		stage = KanbanStage.find_by_name(stage_name)
		states = []
		states = KanbanState.find_all_by_stage_id(stage.id) if !states.nil?
		statuses = states.map {|s| IssueStatusKanbanState.status_id(s.id)}.uniq
		return statuses
	end

	def wip_issues_params(user)
		return {:set_filter => "1",:f => [:status_id,:assigned_to_id],
			:op => {:status_id => "=", :assigned_to_id => "="},
			:v => {:assigned_to_id => ["#{user.id}"], :status_id => @wip_statuses}
		}
	end

	def planed_issues(principal)
		conditions = ["assigned_to_id=? ",principal.id]
		@planed_statuses.each do |x|
			rp = (@planed_statuses.first == x) ? "and" : "or"
			conditions[0] += " #{rp} " + "status_id = ?"
			conditions << x
		end
		count = Issue.count(:conditions => conditions)

		params = {:set_filter => "1",:f => [:status_id,:assigned_to_id],
			:op => {:status_id => "=", :assigned_to_id => "="},
			:v => {:assigned_to_id => ["#{principal.id}"], :status_id => @planed_statuses}}
		return  {:count => count, :params => params}
	end

	def testing_issues(principal)
		conditions = ["#{KanbanCard.table_name}.developer_id=? ",principal.id]
		@test_statuses.each do |x|
			rp = (@test_statuses.first == x) ? "and" : "or"
			conditions[0] += " #{rp} " + "status_id = ?"
			conditions << x
		end
		count = Issue.count(:conditions => conditions, :include => :kanban_card)

		params = {:set_filter => "1",:f => [:status_id,:assigned_to_id],
			:op => {:status_id => "=", :assigned_to_id => "="},
			:v => {:assigned_to_id => ["#{principal.id}"], :status_id => @planed_statuses}}
		return  {:count => count, :params => params}
	end


end
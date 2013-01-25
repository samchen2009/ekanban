class KanbanReportsController < ApplicationController

	def users(group=nil,project=nil)
		#get the users in a group according to project.
		group = (group == nil? || group == "0") ? nil : Group.to_group(group)
		project = (project == nil? || project == "0") ? nil : Project.to_project(project)
		users = group.nil? ? User.find(:all, :conditions => ["lastname != 'Admin' and lastname !='Anonymous'"]) : User.in_group(group)
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

		@project = Project.find(params[:project_id]) if !params[:project_id].nil? and params[:project_id]!="0"
		@group = Group.find(params[:group_id]) if !params[:group_id].nil? and params[:group_id]!="0"
		@wip_statuses = statuses("In Progress")
		@planed_statuses = statuses("Planed")
		@test_statuses = statuses("Test")
		@release_statuses = statuses("Release")
		@closed_statuses = statuses("Closed")
		@in_progress_statuses = statuses("In Progress")

		@from = params[:from]
		@to = params[:to]
	end

	def weekly_journals
		journals = Journal.issues.between(@from,@to).contains("Weekly")
	end
	def summary_and_todo(notes)
		notes = notes.gsub(/\r?\n/, '<br/>')
		summary = todo = ""
		matches = /.*[t|T]odo:(.*$)/.match(notes)
		todo = matches[1] if !matches.nil?
		matches = matches.nil? ? /.*[w|W]eekly:(.*$)/.match(notes) : /.*[w|W]eekly:(.*?)[t|T]odo:/.match(notes)
		summary = matches[1] if !matches.nil?
		return summary,todo
	end

	def weekly_columns()
		return ["Owner","#","ID","Issue", "Status", "Project", "Group", "Weekly Summary","Todo"]
	end

	def kanban_reports_tabs
    	tabs = [{:name => 'Statistics', :action => :kanban_statistics, :partial => 'statistics', :label => :label_kanban_statistics},
            {:name => 'Weekly', :action => :kanban_weekly, :partial => 'weekly', :label => :label_kanban_weekly},
            {:name => 'Charts', :action => :kanban_chart, :partial => 'charts', :label => :label_kanban_charts},
            ]
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
			return issues_count_and_link(user,@in_progress_statuses)
		when "wip_limit"
			return {:count => user.wip_limit, :params => edit_user_path(user.id)}
		when "loading"
			return {:count =>  issues_count_and_link(user,@in_progress_statuses)[:count] * 100 / user.wip_limit,:params => nil}
		when "planed"
			return issues_count_and_link(user,@planed_statuses)
		when "test"
			return issues_count_and_link(user,@test_statuses)
		end
 	end

 	def issues_count_and_link(principal,statuses)
 		if principal.nil?
 			conditions = ["assigned_to_id != 0"]
 		else principal.nil?
 			conditions = ["assigned_to_id=? ",principal.id]
 		end

 		if !@project.nil?
 			conditions[0] += " and project_id=? "
 			conditions << @project.id
 		else
 			conditions[0] += " and project_id!=0 "
 		end

 		conditions[0] += " and status_id in (?)"
 		conditions << statuses
		#statuses.each_with_index do |x,i|
		#	rp = (i == 0) ? "and" : "or"
		#	conditions[0] += " #{rp} " + "status_id = ?"
		#	conditions << x
		#end
		count = Issue.count(:conditions => conditions)
		project_ids = @project.nil? ? @projects.map {|p| p.id} : [@project.id]
		params = {:set_filter => "1",:f => [:status_id,:assigned_to_id,:project_id],
			:op => {:status_id => "=", :assigned_to_id => "=", :project_id => "="},
			:v => {:assigned_to_id => ["#{principal.id}"], :status_id => statuses, :project_id => project_ids}}
		return  {:count => count, :params => params}
 	end

	def total_issues(principal)
		if @project.nil?
			count = Issue.open.count(:conditions => "assigned_to_id=#{principal.id}")
		else
			count = Issue.open.count(:conditions => "assigned_to_id=#{principal.id} and project_id=#{@project.id}")
		end
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
		if @project.nil?
			return {:set_filter => "1",:f => [:status_id,:assigned_to_id],
			:op => {:status_id => "=", :assigned_to_id => "="},
			:v => {:assigned_to_id => ["#{user.id}"], :status_id => @wip_statuses}}
		else
			return {:set_filter => "1",:f => [:status_id,:assigned_to_id,:project_id],
			:op => {:status_id => "=", :assigned_to_id => "=",:project_id => "="},
			:v => {:assigned_to_id => ["#{user.id}"], :status_id => @wip_statuses},:project_id => @project.id}
		end
	end
end
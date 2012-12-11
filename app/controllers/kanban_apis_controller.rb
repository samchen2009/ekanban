class KanbanApisController < ApplicationController

def kanban_state_issue_status
	render :json => {:kanban_state_issue_status => IssueStatusKanbanState.all}
end

def kanban_workflow
	render :json => {:kanban_workflow => KanbanWorkflow.all}
end

def issue_workflow
	render :json => {:issue_workflow => Workflow.all}
end

def user_roles_for_project()
	roles = User.find(params[:user_id]).roles_for_project(params[:project_id])
	render :json => {"roles" => roles}
end
# params
#   wip:
#     pane_id:  get wip in specific pane (specific project, 0 means total wip (in other panes, in other projects)
#     user_id: user's wip
#   wiplimit:
#     user or group's global limit. (no matter project,pane,role)
#
def user_wip_and_limit
	#An user may work for multiple project
	if (params[:pane_id].nil?)
		wip = KanbanCard.open().by_user(params[:user_id]).in_progress()
	else
		wip = KanbanPane.wip(params[:pane_id],nil,params[:user_id]);
	end
	wip_limit = User.find(params[:user_id]).wip_limit
	render :json => {:wip => wip, :wip_limit => wip_limit}
end

def group_wip_and_limit
	if params[:pane_id] == 0 or params[:pane_id].nil?
		wip = KanbanCard.open().byGroup(params[:group_id]).in_progress()
	else
		wip = KanbanPane.wip(params[:pane_id],params[:group_id],nil);
	end
	wip_limit = Group.find(params[:group_id]).wip_limit()
	render :json => {:wip => wip, :wip_limit => wip_limit}
end

def kanban_states
	render :json => {:kanban_states => KanbanState.all}
end

def pane_wip_and_limit
	pane = KanbanPane.find(params[:pane_id])
	wip_limit = pane.wip_limit(params[:project_id],params[:group_id],params[:member_id])
	wip = KanbanPane.wip(pane,params[:group_id],params[:user_id])
	render :json => {:wip => wip, :wip_limit => wip_limit}
end

end
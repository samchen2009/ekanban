class KanbanApisController < ApplicationController

def kanban_state_issue_status
	render :json => {:kanban_state_issue_status => IssueStatusKanbanState.all}
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
	if (params[:pane_id] == 0)
		wip = KanbanCard.open().byUser(params[:user_id])
	else
		wip = KanbanPane.wip(params[:pane_id],nil,params[:user_id]);
	end
	wip_limit = User.find(params[:user_id]).wip_limit
	render :json => {:wip => wip, :wip_limit => wip_limit}
end

def group_wip_and_limit
	if params[:pane_id] == 0 or params[:pane_id].nil?
		wip = KanbanCard.open().byGroup(params[:group_id])
	else
		wip = KanbanPane.wip(params[:pane_id],params[:group_id],nil);
	end
	wip_limit = Group.find(params[:group_id]).wip_limit()
	render :json => {:wip => wip, :wip_limit => wip_limit}
end

def pane_wip_and_limit
	pane = KanbanPane.find(params[:pane_id])
	wip_limit = pane.wip_limit(params[:project_id],params[:group_id],params[:member_id])
	wip = KanbanPane.wip(pane,params[:group_id],params[:user_id])
	render :json => {:wip => wip, :wip_limit => wip_limit}
end

end
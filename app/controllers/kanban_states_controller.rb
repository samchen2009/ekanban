class KanbanStatesController < ApplicationController

	def new
		@tracker = Tracker.find(params[:tracker_id])
		@trackers = Tracker.all
		@state = KanbanState.new
		@stages = KanbanStage.all
		@issue_statuses = IssueStatus.all
	end

	def create
		@state = KanbanState.new(params[:kanban_state])
		if request.post? && @state.save
      		render :action => 'index'
    	else
      		render :action => 'new'
    	end
	end

	def destroy
		@state = KanbanState.find(params[:id])
		@state.delete
		render :action => "index"
	end

	def setup
		@trackers = Tracker.all
		render :action => 'index'
	end

	def edit
		@state = KanbanState.find(params[:id])
		@tracker = Tracker.find(params[:tracker_id])
		@trackers = Tracker.all
		@stages = KanbanStage.all
		@issue_statuses = IssueStatus.all
	end

	def update
		@state = KanbanState.find(params[:id]);
		@state.attributes = params[:kanban_state]
		if request.put? && @state.save
      		render :action => 'index'
    	else
      		render :action => 'edit'
    	end
	end

	def index
		@states = KanbanState.by_tracker(params[:tracker_id])
	end

	def setup_tabs
	    tabs = [{:name => 'States', :action => :kanban_general, :partial => 'state_list', :label => :label_kanban_states},
            {:name => 'Stages', :action => :kanban_pane, :partial => 'stage_list', :label => :label_kanban_stages},
            {:name => 'Maps', :action => :kanban_workflow, :partial => 'maps', :label => :label_kanban_maps},
            ]
    #tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
  end

end
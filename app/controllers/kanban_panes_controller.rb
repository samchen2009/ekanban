class KanbanPanesController < ApplicationController
  unloadable

  respond_to :json

  def index
  	@panes = KanbanPane.where("kanban_id = #{params[:kanban_id]}");
  	stages = []
  	@panes.each do |p|
  	  stages << p.kanban_state.kanban_stage
 	    p.wip_limit =	p.wip_limit_by_view(params[:group_id],params[:member_id])
  	end
    respond_with([@panes,stages]);
  end

  def new
    @project = Project.find(params[:project_id])
    @kanban = Kanban.find(params[:kanban_id])
    used_states = []
    @states = KanbanState.find_all_by_tracker_id(@kanban.tracker_id)
    @kanban.kanban_pane.each {|p| used_states << p.kanban_state}
    @states = @states.reject{|s| used_states.include?(s)}
    @roles = Role.all
    @pane = KanbanPane.new
  end

  def create
    debugger
    @pane = KanbanPane.new(params[:kanban_pane])
    @pane.kanban_id = params[:kanban_id]
    if request.post? && @pane.save
      redirect_to edit_project_kanban_path(params[:project_id],params[:kanban_id]), :tab => 'States'
    else
      render :action => 'new'
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @kanban = Kanban.find(params[:kanban_id])
    used_states = []
    @states = KanbanState.find_all_by_tracker_id(@kanban.tracker_id)
    @kanban.kanban_pane.each {|p| used_states << p.kanban_state if p.id != params[:id].to_i}
    @states = @states.reject{|s| used_states.include?(s)}
    debugger
    @roles = Role.all
    @pane = KanbanPane.find(params[:id])
  end

  def show
  	@pane = KanbanPane.find(params[:id])
  	@stage = @pane.kanban_state.kanban_stage
  	respond_with([@pane,@stage])
  end
end

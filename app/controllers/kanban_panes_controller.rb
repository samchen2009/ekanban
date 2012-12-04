class KanbanPanesController < ApplicationController
  unloadable

  respond_to :json

  def index
  	@panes = KanbanPane.where("kanban_id = #{params[:kanban_id]}");
  	stages = []
  	@panes.each {|p| stages << p.kanban_state.kanban_stage.name}
    respond_with([@panes,stages]);
  end

  def create
  end

  def show
  	@pane = KanbanPane.find(params[:id])
  	@stage = @pane.kanban_state.kanban_stage.name
  	respond_with([@pane,@stage])
  end
end

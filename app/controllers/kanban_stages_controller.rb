class KanbanStagesController < ApplicationController

	def new
		@stage = KanbanStage.new
	end

	def create
		@stage = KanbanStage.new(params[:kanban_stage])
		if request.post? && @stage.save
      		render :action => 'index'
    	else
      		render :action => 'new'
    	end
	end

	def destroy
		@stage = KanbanStage.find(params[:id])
		@stage.delete
		render :action => "index"
	end

	def edit
		@stage = KanbanStage.find(params[:id])
	end

	def update
		@stage = KanbanStage.find(params[:id]);
		@stage.attributes = params[:kanban_stage]
		if request.put? && @stage.save
      		render :action => 'index'
    	else
      		render :action => 'edit'
    	end
	end

	def index
		#redirect_to :controller => "kanban_states", :action => "setup", :tab => 'Stages'
	end
end
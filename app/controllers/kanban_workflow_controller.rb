class KanbanWorkflowController < ApplicationController
  unloadable


  def index
  end

  def edit
  end

  def create
  end

  def transition(from,to,kanban)
  	KanbanWorkflow.find_by_old_state_id_and_new_state_id_and_kanban_id(from,to,kanban)
  end

  def check_role?(role_id)
   anonymous = Role.find_by_name("Anonymous").id
   nonmember = Role.find_by_name("Non member").id
   return false if role_id == anonymous or role_id == nonmember
   return true
  end

  def update
  	@project = params[:project_id]
  	@kanban = params[:kanban_id]
  	flow = params[:flow]
  	num = flow.size
  	flow.each do |f|
  	  from = f[0].to_i
  	  f[1].each do |k,v|
  	  	to = k.to_i
  	  	role = v[0].to_i
  	  	if from != to
  	  		transition = transition(from,to,params[:kanban_id])
  	  		if !transition.nil?
  	  			if role  == 0 #disable the transition now.
  	  				transition.delete
  	  			else
  	  				transition.role_id = role
  	  				transition.check_role = check_role?(role)
  	  			end
  	  			transition.save!
  	  		elsif role > 0
  	  			transition = KanbanWorkflow.new
  	  			transition.kanban_id = params[:kanban_id]
  	  			transition.old_state_id = from
  	  			transition.new_state_id = to
  	  			transition.role_id = role
  	  			transition.check_role = check_role?(role)
  	  			transition.save!
  	  		end
  	  	end
  	  end
  	end
  	redirect_to edit_project_kanban_path(params[:project_id],params[:kanban_id], :tab => 'Workflow')
  end
end

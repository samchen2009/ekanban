class KanbanCardsController < ApplicationController
  unloadable


  def index
  	respond_to :json
  end

  def create
  end

  def show
  	respond_to :json,:html
  	@card = KanbanCard.find(params[:id])
  	@issue = @card.issue
  	respond_with([@card,@issue])
  end

  def save_with_issues()
    Issue.transaction do
      # TODO: Rename hook
      if ( !@card.save || !@issue.save || !@journal.save)
        raise ActiveRecord::Rollback
        return false
      end
    end
    true
  end

  def update
    @issue = Issue.find(params[:issue_id])
    @card = KanbanCard.find_by_issue_id(params[:issue_id])
    @journal = @issue.init_journal(User.current, params[:comment][:notes])
    @card.developer_id = params[:developer_id]
    @card.verifier_id = params[:verifier_id]
    @card.kanban_pane_id = params[:kanban_pane_id]  if params[:kanban_pane_id].to_i > 0
    @issue.status_id = params[:issue_status_id]
    @issue.assigned_to_id = params[:assignee_id]

    @saved = false
    begin
      @saved = save_with_issues();
    rescue ActiveRecord::StaleObjectError
    end

  	respond_to do |format|
      format.json do
        if @saved
          project_id = @card.kanban_pane.kanban.project_id
          redirect_to project_kanbans_path(project_id)
        else
          render :nothing => true
        end
      end
      format.js do
        render :partial => "update", :locals => {"errors" => "unknown"}
      end
    end
  end
end

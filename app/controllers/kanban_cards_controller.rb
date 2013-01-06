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
      #must save @issue first, otherwise, the wip check will failed.
      return @card.save && @journal.save if @issue.save
    end
    false
  end

  def update
    @issue = Issue.find(params[:issue_id])
    @card = KanbanCard.find_by_issue_id(params[:issue_id])
    old_card = @card.dup
    @journal = @issue.init_journal(User.current, params[:comment][:notes])
    @card.developer_id = params[:developer_id]
    @card.verifier_id = params[:verifier_id]
    pane = KanbanPane.find_by_kanban_id_and_kanban_state_id(@card.kanban_pane.kanban.id, params[:kanban_state_id])
    @card.kanban_pane_id = pane.id
    @issue.status_id = params[:issue_status_id]
    @issue.assigned_to_id = params[:assignee_id]
    @issue.start_date = params[:start_date_]
    @issue.due_date = params[:due_date_]

    @saved = false
    begin
      @saved = save_with_issues();
    rescue ActiveRecord::StaleObjectError
    end
    KanbanCardJournal.build(old_card,@card,@journal) if @saved == true

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
        render :partial => "update", :locals => {"errors" => "Error! Please check with admin!"}
      end
    end
  end
end

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

  def update
    debugger
    issue = Issue.find(params[:issue_id])
    card = KanbanCard.where("issue_id = #{params[:issue_id]}")
    issue.status_id = params[:issue_status_id]
    issue.assigned_to_id = params[:assignee_id]
  	respond_to do |format|
      format.json {render :nothing => true}
    end
  end
end

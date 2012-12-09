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
  	respond_to do |format|
      format.json {render :nothing => true}
    end
  end
end

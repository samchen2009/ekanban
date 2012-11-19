class KanbansController < ApplicationController
  unloadable


  def index
  	@kanbans = Kanban.valid()
  	@kanban = @kanbans.first
  	@panes = @kanban.kanban_pane
  	@panes.each do |pane|
  		pane.name = pane.kanban_state.name
  	end
  end

  def create
  	
  end
end

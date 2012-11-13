class KanbansController < ApplicationController
  unloadable


  def index
  	@Kanbans = Kanban.valid()
  end

  def create
  	
  end
end

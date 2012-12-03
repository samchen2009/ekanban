class  KanbanStageHelper

  attr_reader :name,:state_name
  attr_accessor :wip,:wip_limit


  def initialize (name, state_name)
    @state_name = []
    @name = name
    @state_name << state_name
    @wip = 10;
    @wip_limit = 100;
  end

  def add(state_name)
    @state_name << state_name if !@state_name.include?(state_name)
  end

  def state_num
    @state_name.size
  end
end


class KanbansController < ApplicationController
  unloadable

  PROJECT_VIEW = 0  #Show selected Kanban in Project view
  GROUP_VIEW = 1    #Show selected Kanban in Group view
  MEMBER_VIEW = 2   #Show selected Kanban in Member view

  def index
    @project = Project.find(params[:project_id])#Get member name of this project
    @members= @project.members
    @principals = @project.principals

    @member = nil
    @principal = nil

    params[:kanban_id] = 0 if params[:kanban_id].nil?
    params[:member_id] = 0 if params[:member_id].nil?
    params[:principal_id] = 0 if params[:principal_id].nil?

    @kanbans = []

    if params[:kanban_id].to_i > 0
        @kanbans << Kanban.find(params[:kanban_id])
    else
        @kanbans = Kanban.by_project(@project)
    end

    if params[:member_id].to_i == 0 and params[:principal_id].to_i == 0
      @view = PROJECT_VIEW
    elsif params[:member_id].to_i > 0
      @view = MEMBER_VIEW
      @member = Member.find(params[:member_id])
    else
      @view = GROUP_VIEW
      @principal = Principal.find(params[:principal_id])
    end

    #Get all kanbans's name
    @kanban_names = @kanbans.collect{|k| k.name}
    respond_to do |format|
      format.html
      format.js { render :partial => "index", :locals => {:view=>@view, :kanbans=>@Kanbans}}
      format.json { render :json => {:kanbans => @kanbans, 
                                     :teams => @principal, 
                                     :member => @member, 
                                     :view => @view}}
    end
  end

  def panes(kanban)
    #Get all kanban stage/state/
    panes = [] if kanban.nil? or !kanban.is_a?(Kanban)
  	panes = kanban.kanban_pane
  end

  def panes_num(kanban)
    panes(kanban).size
  end

  def cards(pane_id)
    pane = KanbanPane.find(pane_id)
    cards = pane.kanban_card
    if !@member.nil?
       cards = cards.by_member(@member)
    elsif !@principal.nil?
       cards = cards.by_group(@principal)
    end
    cards
  end

  def assignee_name(assignee)
    assignee.is_a?(Principal)? assignee.name : "unassigned"
  end

  def stages(panes)
    return nil if panes.empty?
    stages = []
    panes.each do |p|
      state = p.kanban_state
      p.name = state.name
      stage_name = state.kanban_stage.name
      stages << KanbanStageHelper.new(stage_name, p.name) if stages.empty?
      i = stages.index {|s| s.name == stage_name}
      if !i.nil?
        stages[i].add (p.name)
      else
        stages << KanbanStageHelper.new(state.kanban_stage.name, p.name)
      end
    end
    return stages
  end

  def states(panes)
    return nil if panes.empty?
    panes.collect {|p| p.kanban_state}.sort {|x,y| x.position <=> y.position}
  end

  def show
    debugger
  end

  def create
  	debugger
  end

  def wip(stage)

  end

  def pane(pane_id)
    pane = KanbanPane.find(pane_id)
  end

  def stage(pane_id)
    pane = pane(pane_id)
    stage = Stage.find(pane.stage_id) if !pane.nil?
  end

  def pane_wip(pane_id)

  end

end

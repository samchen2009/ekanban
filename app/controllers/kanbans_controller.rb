class  KanbanStageHelper

  attr_reader :id,:name,:state_name
  attr_accessor :wip,:wip_limit


  def initialize (id, name, state_name)
    @state_name = []
    @name = name
    @id = id
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
    @user = User.current

    @roles = @user.roles_for_project(@project)

    @member = nil
    @principal = nil

    @issue_statuss = IssueStatus.all
    @kanban_states = KanbanState.all
    @issue_status_kanban_state = IssueStatusKanbanState.all
    @kanban_flows = KanbanWorkflow.all

    params[:kanban_id] = 0 if params[:kanban_id].nil?
    params[:member_id] = 0 if params[:member_id].nil?
    params[:principal_id] = 0 if params[:principal_id].nil?

    @kanbans = []

    if params[:kanban_id].to_i > 0
        @kanbans << Kanban.find(params[:kanban_id])
    else
        @kanbans = Kanban.by_project(@project).where("is_valid = 't'")
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
    assignee.is_a?(Principal)? assignee.alias : "unassigned"
  end

  def stages(panes)
    return nil if panes.empty?
    stages = []
    panes.each do |p|
      state = p.kanban_state
      p.name = state.name
      stage = state.kanban_stage
      stages << KanbanStageHelper.new(stage.id,stage.name, p.name) if stages.empty?
      i = stages.index {|s| s.name == stage.name}
      if !i.nil?
        stages[i].add (p.name)
      else
        stages << KanbanStageHelper.new(stage.id, stage.name, p.name)
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

  def new
    @kanban = Kanban.new
    @project = Project.find(params[:project_id])
    used_trackers = []
    Kanban.all.each {|k| used_trackers << k.tracker if k.is_valid}
    @trackers = Tracker.all.reject {|t| used_trackers.include?(t)}
  end

  def create
    @kanban = Kanban.new(params[:kanban])
    @kanban.created_by = User.current.id
    @kanban.project_id = params[:project_id]
    if request.post? && @kanban.save
      redirect_to settings_project_path(params[:project_id], :tab => 'Kanban')
    else
      render :action => 'new'
    end
  end

  def kanban_settings_tabs
    tabs = [{:name => 'General', :action => :kanban_general, :partial => 'general', :label => :label_kanban_general},
            {:name => 'Panes', :action => :kanban_pane, :partial => 'panes', :label => :label_kanban_panes},
            {:name => 'Workflow', :action => :kanban_workflow, :partial => 'workflow', :label => :label_kanban_workflow},
            ]
    #tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
  end

  def update
    @project = Project.find(params[:project_id])
    @kanban = Kanban.find(params[:id])
    if (params[:position])
      @kanban.kanban_pane.each {|p| p.position = params[:position].index("#{p.id}") + 1; p.save}
    end
    if (params[:kanban])
      @kanban.description = params[:kanban][:description]
      @kanban.tracker_id  = params[:kanban][:tracker_id]
      @kanban.name  = params[:kanban][:name]
      @kanban.is_valid  = params[:kanban][:is_valid]
      @kanban.save
    end

    respond_to do |format|
      format.json {render :nothing => true}
      format.html do
        if (params[:position])
          render :partial => "edit_js"
        else
          redirect_to settings_project_path(params[:project_id], :tab => 'Kanban')
        end
      end
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @kanban = Kanban.find(params[:id])
    used_trackers = []
    Kanban.all.each {|k| used_trackers << k.tracker if k.is_valid and k.id != params[:id].to_i}
    @trackers = Tracker.all.reject {|t| used_trackers.include?(t)}
  end

  def destroy
    puts params
    @kanban = Kanban.find(params[:id])
    @kanban.is_valid = 'f'
    @saved = @kanban.save
    respond_to do |format|
      format.js do
        render :partial => "update"
      end
      format.html { redirect_to :controller => 'projects', :action => 'settings', :id => params[:project_id], :tab => 'Kanban' }
    end
  end

  def pane(pane_id)
    pane = KanbanPane.find(pane_id)
  end

  def stage(pane_id)
    pane = pane(pane_id)
    stage = Stage.find(pane.stage_id) if !pane.nil?
  end

end

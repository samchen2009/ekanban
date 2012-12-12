# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do
	resources :projects do
		resources  :kanbans do
			resources :kanban_panes 
		end
	end
	resource :kanban_cards

	match 'kanban_apis/kanban_state_issue_status', :controller => 'kanban_apis', :action => 'kanban_state_issue_status', :via => :get
	match 'kanban_apis/kanban_workflow', :controller => 'kanban_apis', :action => 'kanban_workflow', :via => :get
	match 'kanban_apis/issue_workflow', :controller => 'kanban_apis', :action => 'issue_workflow', :via => :get
	match 'kanban_apis/kanban_states', :controller => 'kanban_apis', :action => 'kanban_states', :via => :get
	match 'project/:project_id/kanbans', :controller => 'kanbans', :action => 'index', :via => :get
	match 'kanban_apis/user_wip_and_limit', :controller => 'kanban_apis', :action => 'user_wip_and_limit', :via => :get
	match 'kanbans/setup', :controller => 'kanbans', :action => 'setup', :via => :get
end

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do
        resources :projects do
                resources  :kanbans do
                        resources :kanban_panes
                        resources :kanban_workflow
                end
        end
        resource :kanban_card

        resources :trackers do
                resources :kanban_states
        end

        resources :kanban_stages

        get 'kanban_apis/kanban_card_journals', :controller => 'kanban_apis', :action => 'kanban_card_journals', :via => :get
        get 'kanban_apis/kanban_state_issue_status', :controller => 'kanban_apis', :action => 'kanban_state_issue_status', :via => :get
        get 'kanban_apis/kanban_workflow', :controller => 'kanban_apis', :action => 'kanban_workflow', :via => :get
        get 'kanban_apis/kanban_states', :controller => 'kanban_apis', :action => 'kanban_states', :via => :get
        put 'kanban_apis/close_issues', :controller => 'kanban_apis', :action => 'close_issues', :via => :put
        get 'project/:project_id/kanbans', :controller => 'kanbans', :action => 'index', :via => :get
        get 'kanban_apis/user_wip_and_limit', :controller => 'kanban_apis', :action => 'user_wip_and_limit', :via => :get
        get 'kanbans/setup', :controller => 'kanbans', :action => 'setup', :via => :get
        get 'kanban_states/setup', :controller=>'kanban_states', :action => 'setup', :via => :get
        put 'issue_status_kanban_states/update', :controller => 'issue_status_kanban_states', :action => "update", :via => :put
        get 'kanbans/copy', :controller => 'kanbans', :action => "copy"
        get 'kanban_reports/index', :controller => 'kanban_reports', :action => "index", :via => :get
        get 'kanban_apis/issue_card_detail', :controller => 'kanban_apis', :action => 'issue_card_detail', :via => :get
end

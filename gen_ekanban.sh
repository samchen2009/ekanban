#/bin/bash

#Models
ruby script/rails generate redmine_plugin ekanban
ruby script/rails generate redmine_plugin_model ekanban Kanban name:string project_id:integer tracker_id:integer created_by:integer created_on:datetime updated_on:datetime is_valid:boolean
ruby script/rails generate redmine_plugin_model ekanban Kanban_State name:string is_default:boolean is_initial:boolean is_closed:boolean tracker_id:integer position:integer
ruby script/rails generate redmine_plugin_model ekanban Kanban_Pane name:string kanban_id:integer wip_limit:integer is_user_wip:integer 
ruby script/rails generate redmine_plugin_model ekanban Issue_Status_Kanban_State issue_status_id:integer kanban_state_id:integer
ruby script/rails generate redmine_plugin_model ekanban Kanban_Card issue_id:integer developer_id:integer tester_id:integer 
ruby script/rails generate redmine_plugin_model ekanban Kanban_Workflow old_state_id:integer new_state_id:integer check_role:boolean check_wip_limit:integer role_id:integer 

#controller
ruby script/rails generate redmine_plugin_controller ekanban kanbans index create
ruby script/rails generate redmine_plugin_controller ekanban kanban_cards index create
ruby script/rails generate redmine_plugin_controller ekanban kanban_panes index create
ruby script/rails generate redmine_plugin_controller ekanban kanban_workflow index create

rake redmine:plugins:migrate

module EKanban
  module Hooks
  	class KanbanSettingHook  < Redmine::Hook::ViewListener
      	def helper_projects_settings_tabs(context = {})
          #if User.current.allowed_to?(:new_tab_action, context[:project])
              context[:tabs].push({ :name    => 'Kanban',
                                    :action  => :setup,
                                    :partial => 'kanbans/setup',
                                    :label   => :label_kanban})
          #end
        end
 	  end


    class ControllerIssuesEditBeforeSaveHook < Redmine::Hook::ViewListener

      def tracker_changed?(issue, card)
      	return card.kanban_pane.Kanban.tracker_id != issue.tracker_id
      end

      def create_kanban_from_issue(issue)
      	kanban = Kanban.new()
      	kanban.name = "Created by system with issue #{issue.id}"
      	kanban.project_id = issue.project_id
      	kanban.tracker_id = issue.tracker_id
      	kanban.is_valid = true;
      	return kanban_pane
      end

      def controller_issues_new_after_save(context={})
      	issue = context[:issue]
      	card = KanbanCard.new
      	kanban = Kanban.find_by_project_id_and_tracker_id(issue.project_id,issue.tracker_id)

      	#KanbanCard.transaction do
      		saved = false;
      		if kanban.nil?
      			saved = false
      			kanban = create_kanban_from_issue(issue)
      			if !kanban.save()
      				Redmine::Rollback()
      				return false
      			end
      		end

      		pane = KanbanPane.find_by_kanban_id(kanban.id)

      		if pane.nil?
      			#by default add a backlog pane.
      			pane = KanbanPane.new()
      			pane.kanban_id = kanban.id
      			pane.kanban_state_id = 1
      			pane.wip_limit = 999
      			pane.wip_limit_auto = false;
      			pane.role_id = 1 #anonymous
      			pane.in_progress = false
      			if !pane.save()
      				Redmine::Rollback()
      				return false
      			end
      		end

      		card.kanban_pane_id = pane.id
      		card.issue_id = issue.id
      		card.developer_id = issue.assigned_to_id
      		card.verifier_id = issue.assigned_to_id

      		if !card.save()
      			Redmine::Rollback()
      			return false
      		end
      	#end
      	true
      end

      def controller_issues_edit_before_save(context={})

       	# Check
       	# 1. user's wip and permission(role).
       	# 2. corresponding pane.
       	# 3. ...
       	issue = context[:issue]
       	card = KanbanCard.find_by_issue_id(issue.id)
       	assignee = issue.assigned_to
  		  new_state = IssueStatusKanbanState.state_id(issue.status_id)
  		  kanban = Kanban.find_by_project_id_and_tracker_id(issue.project_id,issue.tracker_id)

  		  return false if kanban.nil?
  		  new_pane = KanbanPane.pane_by(new_state,kanban)
  		  return flase if new_pane.nil?

  		  # Tracker changed.
       	if kanban.id != card.kanban_pane.kanban.id
       		old_state = new_state
       		old_pane  = new_pane
       	else
  		    old_state = card.kanban_pane.kanban_state_id
  		    old_pane  = card.kanban_pane
  		  end

    		return false if !KanbanWorkflow.transition_allowed?(old_state,new_state)

    		developer = card.developer
    		verifier  = card.verifier
    		pre_assignee = developer.has_role?(old_pane.role_id,issue.project) ? developer : verifier

    		#assignee changed? - need to check user wip
    		if (pre_assignee.id != assignee.id)
    			# change from developer to verifier?
    			if assignee.wip == assignee.wip_limit
    				puts "assignee #{assignee.alias} reached wip_limit already!"
    				return false
    			end
    		end

    		#issue status change? - need to check pane's wip and wip limit
    		if !KanbanState.in_same_stage?(old_state, new_state)
    			if new_pane.wip_limit_by_view() == KanbanPane.wip(new_pane)
    				puts "Pane #{new_pane.id} #{new_pane.name} reached wip_limit already!"
    				return false
    			end
    		end

    		final_assignee = nil
    		#need to check the wip_limit (both user's and pane's)
    		if !new_pane.accept_user?(assignee)
    			puts "Pane #{new_pane.id} #{new_pane.name} not accept #{assignee.alias}!"
    			if (assignee.id != developer.id) and (assignee.id != verifier.id)
    				puts "Assignee is new, rejected!"
    				return false
    			else
    				if (assignee.id == developer.id)
    					if !new_pane.accept_user?(verifier)
    						puts "assignee is developer, verifier #{verifier.alias} not accept"
    						return false
    					end
    					final_assignee = verifier
    				else
    					if !new_pane.accept_user?(developer)
    						puts "assignee is verifier, check developer"
    						return false
    					end
    					final_assignee = developer
    				end
    			end
    		else
    			#new assignee accpeted. change verifier or developoer.
    			final_assignee = assignee
    			developer = final_assignee if assignee.has_role?("Developer", issue.project)
    			verifier  = final_assignee if assignee.has_role?("Verifier", issue.project)
    		end

    		#issue update.
    		issue.assigned_to_id = final_assignee.id

    		#kanban card update
    		card.developer_id = developer.id
    		card.verifier_id = verifier.id
    		card.kanban_pane_id = new_pane.id

    		return card.save!
      end
    end
  end
end
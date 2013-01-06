class KanbanApisController < ApplicationController

	def kanban_state_issue_status
		render :json => {:kanban_state_issue_status => IssueStatusKanbanState.all}
	end

	def kanban_workflow
		render :json => {:kanban_workflow => KanbanWorkflow.all}
	end

	def issue_workflow
		render :json => {:issue_workflow => Workflow.all}
	end

	def user_roles_for_project()
		roles = User.find(params[:user_id]).roles_for_project(params[:project_id])
		render :json => {"roles" => roles}
	end
	# params
	#   wip:
	#     pane_id:  get wip in specific pane (specific project, 0 means total wip (in other panes, in other projects)
	#     user_id: user's wip
	#   wiplimit:
	#     user or group's global limit. (no matter project,pane,role)
	#
	def user_wip_and_limit
		#An user may work for multiple project
		if (params[:pane_id].nil?)
			wip = KanbanCard.open().by_user(params[:user_id]).in_progress()
		else
			wip = KanbanPane.wip(params[:pane_id],nil,params[:user_id]);
		end
		wip_limit = User.find(params[:user_id]).wip_limit
		render :json => {:wip => wip, :wip_limit => wip_limit}
	end

	def group_wip_and_limit
		if params[:pane_id] == 0 or params[:pane_id].nil?
			wip = KanbanCard.open().byGroup(params[:group_id]).in_progress()
		else
			wip = KanbanPane.wip(params[:pane_id],params[:group_id],nil);
		end
		wip_limit = Group.find(params[:group_id]).wip_limit()
		render :json => {:wip => wip, :wip_limit => wip_limit}
	end

	def kanban_states
		render :json => {:kanban_states => KanbanState.all}
	end

	def pane_wip_and_limit
		pane = KanbanPane.find(params[:pane_id])
		wip_limit = pane.wip_limit(params[:project_id],params[:group_id],params[:member_id])
		wip = KanbanPane.wip(pane,params[:group_id],params[:user_id])
		render :json => {:wip => wip, :wip_limit => wip_limit}
	end

	def detail_to_desc(journal)
		prop_keys = ["status_id","priority_id", "fixed_version_id", "done_ratio","category_id","assigned_to_id"]
		actions = ['Set','Changed',"Set","",'Set', 'Change']
		classes = ["IssueStatus", "Enumeration","Version", "","IssueCategory", "User"]
		desc = ""
		journal.details.each do |d|
			index = prop_keys.index(d.prop_key)
			next if index.nil?
			old_value = classes[index] == "" ?  d.old_value : d.old_value.nil? ? "null" : eval(classes[index]).find(d.old_value).name
			new_value = classes[index] == "" ?  d.value : d.value.nil? ? "null" : eval(classes[index]).find(d.value).name
			#desc += "  #{actions[index]} #{prop_keys[index].split("_id")[0]} from '#{old_value}' to '#{new_value}'<br/>"
			desc += "  <strong>* #{prop_keys[index].split("_id")[0]}:</strong> '#{old_value}'  ->  '#{new_value}'<br/>"
		end
		desc
	end

    #Json format
    #  : => {pane:(id), from:(datetime), to:(datetime), assignee:(name)}
    #    :details => [{note:, prop_key: ("priority_id", "fixed_version_id", "done_ratio"),:old_value, :new_value}]
    #
    #
	def kanban_card_journals
		issue = Issue.find(params[:issue_id])
		card = KanbanCard.find_by_issue_id(params[:issue_id])
		card_journals = [];

		start = {}
		card.kanban_card_journals.each do |j|
			details = j.details.select{|d| d.prop_key == "kanban_pane_id" ||
				                d.prop_key == "developer_id" ||
				                d.prop_key == "verifier_id"}
			started = !start.empty?
			if details
				if (!started)
				  start[:from] = j.created_at.utc.strftime("%Y/%m/%d %H:%M:%S UTC")
				  start[:journal_id] = j.issue_journal_id
				  start[:author] = {:id => issue.author.id, :name => issue.author.alias, :email => issue.author.mail}
				else
				  start[:to] = j.created_at.utc.strftime("%Y/%m/%d %H:%M:%S UTC")
				  puts "collect: #{start[:from]} - #{start[:to]}, pand:#{start[:pane_id]}"
				  card_journals << start
				  start = start.dup
				end

				details.each do |d|
					if d.prop_key == "kanban_pane_id"
						puts "pane #{start[:pane_id]} -> #{d.new_value} (#{d.old_value})"
						start[:pane_id] = d.new_value
					end
					if d.prop_key == "developer_id"
						developer = User.find(d.new_value)
						start[:developer] = {:id => developer.id, :name => developer.alias, :email => developer.mail}
					end
					if d.prop_key == "verifier_id"
						verifier = User.find(d.new_value)
						start[:verifier] = {:id => verifier.id, :name => verifier.alias, :email => verifier.mail}
					end
				end
				#debugger
				#if (started)
				#	card_journals << start
				#end
				start[:journal_id] = j.issue_journal_id
				start[:from] = start[:to] if started
			end
		end
		if (card.kanban_card_journals.size > 0)
			start[:to] = Time.now.utc.strftime("%Y/%m/%d %H:%M:%S UTC")
			card_journals << start
		end

		issue_journals = []
		issue.journals.each do |j|
			desc = detail_to_desc(j)
			issue_journals << {
				:journal => j, :details => j.details, :desc => desc, :author => User.find(j.user_id).alias
			}
		end
		render :json => {:card_journals => card_journals,:issue_journals => issue_journals}
	end
end
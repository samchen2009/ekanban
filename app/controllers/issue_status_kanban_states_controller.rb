class IssueStatusKanbanStatesController < ApplicationController
	def update
		puts params
		states = KanbanState.find_all_by_tracker_id(params[:tracker_id])
		old_maps = {}
		states.map do |state|
			old_maps[state.id.to_s] = state.issue_status_kanban_state.map {|m| m.issue_status_id.to_s} if state.issue_status_kanban_state
		end
		new_maps = params[:maps]
		diff = new_maps.diff(old_maps)
		diff.each do |k,v|
			removeds = (old_maps[k] || []) - (new_maps[k] || [])
			addeds = (new_maps[k] || [])- (old_maps[k] || [])
			puts removeds
			puts addeds

			removeds.each do |r|
				rec = IssueStatusKanbanState.find_by_issue_status_id_and_kanban_state_id(r,k)
				rec.delete if rec
			end

			addeds.each do |a|
				rec = IssueStatusKanbanState.new
				rec.kanban_state_id = k.to_i
				rec.issue_status_id = a.to_i
				rec.save
			end
 	  	end
	  	redirect_to :controller => "kanban_states", :action => "setup", :tab => 'Maps'
	end
end
class IssueStatusKanbanStatesController < ApplicationController
	def update
		puts params
		states = KanbanState.find_all_by_tracker_id(params[:tracker_id])
		all_maps = IssueStatusKanbanState.all
		old_maps = {}
		states.map do |state|
			old_maps[state.id.to_s] = state.issue_status_kanban_state.map {|m| m.issue_status_id.to_s} if state.issue_status_kanban_state
		end
		params[:maps].each do |k,v|
			removeds = old_maps[k] - v
			addeds = v - old_maps[k]
			puts removeds
			puts addeds

			removeds.each do |r|
				rec = all_maps.detect {|m| m.kanban_state_id == k.to_i and m.issue_status_id == r.to_i}
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
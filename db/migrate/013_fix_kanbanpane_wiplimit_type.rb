class FixKanbanpaneWiplimitType < ActiveRecord::Migration
	def self.up
  		change_column :kanban_panes, :wip_limit, :integer, :default => 1, :null => false
  	end
	
	def self.down
	    execute <<-SQL
	       UPDATE kanban_panes SET wip_limit = 1 WHERE wip_limit > 1;
	    SQL
		
  		change_column :kanban_panes, :wip_limit, :boolean, :default => 1, :null => false
  	end
 end

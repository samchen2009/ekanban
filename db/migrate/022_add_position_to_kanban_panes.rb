class AddPositionToKanbanPanes < ActiveRecord::Migration
  def change
  	#table "user"
  	add_column :kanban_panes, :position, :integer, :default=>1
  end
end
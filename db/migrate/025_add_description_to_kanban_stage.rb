class AddDescriptionToKanbanStage < ActiveRecord::Migration
  def change
  	add_column :kanban_stages, :description, :text, :limit => 128
  end
end
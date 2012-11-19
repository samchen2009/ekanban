class CreateKanbanStages < ActiveRecord::Migration
  def change
    create_table :kanban_stages do |t|
      t.string :name
    end
  end
end

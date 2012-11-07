class CreateKanbans < ActiveRecord::Migration
  def change
    create_table :kanbans do |t|
      t.string :name
      t.integer :project_id
      t.integer :tracker_id
      t.integer :created_by
      t.datetime :created_on
      t.datetime :updated_on
      t.boolean :is_valid
    end
  end
end

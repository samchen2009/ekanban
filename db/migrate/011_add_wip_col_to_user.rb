class AddWipColToUser < ActiveRecord::Migration
  def change
  	#table "user"
  	add_column :users, :wip_limit, :integer, :default=>2
  end
end

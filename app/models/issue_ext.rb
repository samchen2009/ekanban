class Issue < ActiveRecord::Base

  scope :by_group, lambda do |group|
  	group = User.current_group if group.nil?
  	{:conditions => ["#{User.table_name}.group_id", group], :include => [:users]}
  end

  scope :by_user, lambda do |user|
  	user = User.current if user.nil?
  	{:conditions => ["#{Issue.table_name}.assigned_to_id", user]}
  end
end
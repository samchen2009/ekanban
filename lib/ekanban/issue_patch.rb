module EKanban
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          has_one :kanban_card
          scope :belong_to_group, lambda {|group|
            group_id = group.nil? ? User.current_group : group.is_a?(Group) ? group.id : group.to_i
            {:conditions => ["#{Issue.table_name}.assigned_to_id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id]}
          }

          scope :belong_to_user, lambda {|user|
            user_id = user.nil? ? User.current :  user.is_a?(User) ? user.id : user.to_i
            {:conditions => ["#{Issue.table_name}.assigned_to_id=?", user_id]}
          }

          #usage
          #Issue.belong_to(user) => all issues belong to user
          #Issue.belong_to(group) => all issues belong to group
          #Issue.belong_to() => all issues belong to current project
          #Issue.belong_to(user,project) => project issue belong to user
          #Issue.belong_to(group,project) => project issue belong to group
          scope :belong_to, lambda {|*args|

            project_id = user_id = group_id = nil
            args.to_a.each do |arg|
              user_id = arg.id if arg.is_a?(User)
              project_id = arg.id if arg.is_a?(Project)
              group_id = arg.id if arg.is_a?(Group)
            end

            conditions = []
            values = []
            if user_id
              conditions << "#{Issue.table_name}.assigned_to_id=?"
              values << user_id
            end
            if group_id
              conditions << "#{Issue.table_name}.assigned_to_id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id = ?)"
              values << group_id
            end
            if project_id
              conditions << "#{Issue.table_name}.project_id=?"
              values << project_id
            end
            {:conditions => conditions.join(' and ').to_a.concat(values)}
          }

          validate :validate_kanban_card_update, :if => Proc.new{!self.new_record?}
          validate :validate_kanban_card_new, :if => Proc.new{self.new_record?}
          validates_presence_of :assigned_to
        end
      end

      module ClassMethods

      end

      module InstanceMethods
        def validate_kanban_card_new
          issue = self
          kanban = Kanban.find_by_project_id_and_tracker_id(issue.project_id,issue.tracker_id)
          return true if kanban.nil?

          state_id = IssueStatusKanbanState.state_id(issue.status_id, issue.tracker_id)
          if (state_id.nil?)
            errors.add(:status_id, ":No kanban state associated with status '#{issue.status.name}', contact redmine admin!")
            return false
          end
          pane = KanbanPane.pane_by(state_id, kanban)
          if pane.nil?
            errors.add(:status_id, ":No kanban pane associated with status '#{issue.status.name}', contact redmine admin!")
            return false
          end

          old_state = KanbanState.find_by_tracker_id_and_is_initial(issue.tracker_id,true)
          if (old_state.nil?)
            errors.add(:status_id, ":No kanban state associated with status 'new', contact redmine admin!")
            return false
          end

          errors.add(:status_id, ":Cannot move from '#{old_state.name}' to '#{pane.name}'") if !KanbanWorkflow.transition_allowed?(old_state.id,state_id,kanban.id)

          #issue status change? - need to check pane's wip and wip limit
          if pane.wip_limit_by_view() <= KanbanPane.wip(pane)
            errors.add :assigned_to_id, ":No resource left in Pane #{pane.name}, increase their wip_limit or add new resources!}"
          end

          assignee = issue.assigned_to
          if assignee.nil?
            errors.add :assigned_to_id, ":Need to specify an assignee"
            return false
          end
          wip = assignee.is_a?(Group) ? assignee.wip(pane.role_id, issue.project_id) : assignee.wip
          wip_limit = assignee.wip_limit
          if pane.in_progress == true and wip >= wip_limit
            errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, who is overloading now! Change assignee or increase his/her wip_limit"
          end

          #need to check the role (both user's and pane's)
          if !pane.accept_user?(assignee)
            errors.add :assigned_to_id, ":Pane #{pane.name} doesn't accept #{assignee.alias}, check his/her roles!"
          end
          puts errors if errors.full_messages.any?
          errors.blank?
        end

        def validate_kanban_card_update
          # Validate
          # 1. user's wip and permission(role).
          # 2. corresponding pane.
          # 3. ...
          issue = self.dup
          assignee = issue.assigned_to

          card = KanbanCard.find_by_issue_id(issue.id)
          kanban = Kanban.find_by_project_id_and_tracker_id(issue.project_id,issue.tracker_id)
          #only apply to issue with kanban created.
          return true if kanban.nil?

          # update existing issue after kanban created.
          if card.nil?
            # create a 'fake' obj
            issue.status_id = @attributes_before_change["status_id"]
            issue.assigned_to = @attributes_before_change["assigned_to"]
            card = KanbanCard.build(issue, nil,false)
            # recover the obj.
            issue = self
            if card.nil?
              errors[:kanban_card] = "Cannot create a Kanban card, check your kanban setting"
              # FIXME: you can change it to false to allow issue to be updated.
              return false
            end
          end

          new_state = IssueStatusKanbanState.state_id(issue.status_id, issue.tracker_id)
          new_pane = KanbanPane.pane_by(new_state,kanban)
          if new_pane.nil?
            errors[:status_id] = ":No Kanban Pane found that associated with this status, check your kanban setting!"
            return true
          end

          if assignee.is_a?(Group) and new_pane.in_progress == true
            errors.add(:assigned_to_id, "Cannot assign issue to a group in 'In Progress' stage!")
            return false
          end

          # Tracker changed.
          if kanban.id != card.kanban_pane.kanban.id
            old_state = new_state
            old_pane  = new_pane
          else
            old_state = card.kanban_pane.kanban_state_id
            old_pane  = card.kanban_pane
          end
          if !KanbanWorkflow.transition_allowed?(old_state,new_state,kanban.id)
            errors.add(:status_id, ":Cannot move from '#{old_pane.name}' to '#{new_pane.name}'") 
          end

          #assignee changed?
          if @attributes_before_change
            before = @attributes_before_change["assigned_to_id"]
            after = issue.assigned_to_id
            if before != after and assignee.wip >= assignee.wip_limit and new_pane.in_progress == true
              errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, who is overloading now! Change owner or increase its wip_limit"
            end
          end

          #issue status change? - need to check pane's wip and wip limit
          if !KanbanState.in_same_stage?(old_state, new_state)
            if new_pane.wip_limit_by_view() <= KanbanPane.wip(new_pane)
              errors.add :status_id, ":Cannot set kanban state to #{new_pane.name}, no resource left, increase their wip_limit or add new resources}"
            end

            assignee = issue.assigned_to
            wip = assignee.is_a?(Group) ? assignee.wip(new_pane.role_id, issue.project_id) : assignee.wip
            wip_limit = assignee.wip_limit
            if old_pane.in_progress == false and new_pane.in_progress == true  and wip >= wip_limit
              errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, who is overloading now! Change assignee or increase his/her wip_limit"
            end
          end

          #need to check the role (both user's and pane's)
          if !new_pane.accept_user?(assignee)
            errors.add :assigned_to_id, ":Cannot assign issue to #{assignee.alias}, Pane #{new_pane.name} doesn't accept him/her, check his roles and wip_limit!"
          end
          puts errors if errors.full_messages.any?
          errors.blank?
          #TODO: validate present of start_date and due_date if status is "accepted"
        end
      end
    end
  end
end

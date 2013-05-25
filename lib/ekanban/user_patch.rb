module EKanban
  module Patches
    module UserPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
        end
      end

      module ClassMethods
        def to_id(user)
          user_id = user.nil? ? User.current : user.is_a?(User) ? user.id : user.to_i
        end

        def to_user(user)
          user = user.nil? ? User.current : user.is_a?(User) ?  user : User.find(user)
        end
      end

      module InstanceMethods
        def has_role?(role,project)
          role = Role.to_role(role)
          return false if role.nil?
          return true if (role.name == "Anonymous" or role.name == "Non member") 
          return self.roles_for_project(Project.to_project(project)).include?(role)
        end

        def wip
          KanbanCard.open().by_user(self).in_progress().size
        end

        def wip_limit
          id = CustomField.find_by_name("WIP limit").id
          v = self.custom_value_for(id)
          v.nil? ? 3 : v.value.to_i
        end
      end
    end
  end
end




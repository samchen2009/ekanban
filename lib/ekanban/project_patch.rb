module EKanban
  module Patches
    module ProjectPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          has_many :kanban
        end
      end

      module ClassMethods
        def to_id(project)
          project_id = project.nil? ? nil : project.is_a?(Project) ? project.id : project.to_i
        end

        def to_project(project)
          project = project.nil? ? nil : project.is_a?(Project) ? project : Project.find(project)
        end
      end

      module InstanceMethods
        #the sum of all member(with specific role) wip limit.
        def wip_limit(role)
          role = Role.to_role(role)
          wip_limit = self.members.inject(0) do |sum,member|
            user = member.user
            (user.roles_for_project(self).include?(role) or role.nil?) ? (sum + user.wip_limit) : sum
          end
        end
      end
    end
  end
end


module EKanban
  module Patches
    module GroupPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
        end
      end

      module ClassMethods
        def to_id(group)
          group_id = group.nil? ? nil : group.is_a?(Group) ? group.id : group.to_i
        end

        def to_group(group)
          group = group.nil? ? nil : group.is_a?(Group) ? group : Group.find(group)
        end
      end

      module InstanceMethods
        def member_of?(project)
          !self.users.detect {|u| u.member_of?(project)}.nil?
        end

        def has_role?(role, project)
          !self.users.detect {|u| u.has_role?(role,project)}.nil?
        end

        def wip_limit(role=nil, project=nil)

          if role.nil? or project.nil?
            users = User.in_group(self)
          else
            project = Project.to_project(project)
            role = Role.to_role(role)
            users = User.member_of(project).in_group(self)
            users.select!{|u| u.roles_for_project(project).include?(role)}
          end

          wip_limit = users.inject(0) {|sum,user| sum + user.wip_limit}
        end

        def wip(role=nil, project=nil)
          if role.nil? or project.nil?
            users = User.in_group(self)
          else
            project = Project.to_project(project)
            role = Role.to_role(role)
            users = User.member_of(project).in_group(self)
            users.select!{|u| u.roles_for_project(project).include?(role)}
          end
          wip = users.inject(0) {|sum,user| sum + user.wip}
        end
      end
    end
  end
end

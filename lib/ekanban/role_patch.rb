module EKanban
  module Patches
    module RolePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
        end
      end

      module ClassMethods
        def to_id(role)
          role_id = role.nil? ? nil : role.is_a?(Role) ? role.id : role.to_i
        end

        def to_role(role)
          role = role.nil? ? nil : role.is_a?(Role) ? role : (role.to_i == 0) ? Role.find_by_name(role) : Role.find(role)
        end
      end

      module InstanceMethods
      end
    end
  end
end
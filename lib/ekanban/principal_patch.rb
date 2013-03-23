module EKanban
  module Patches
    module PrincipalPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do

        end
      end


      module ClassMethods

      end

      module InstanceMethods
        def alias
          return self.login if self.login != ""
          return self.firstname + " " + self.lastname
        end
      end
    end
  end
end
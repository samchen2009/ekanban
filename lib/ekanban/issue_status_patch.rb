module EKanban
  module Patches
    module IssueStatusPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          has_many :issue_status_kanban_state
          has_many :kanban_state, :through => :issue_status_kanban_state
        end
      end

      module ClassMethods
        def closed_id
          #IssueStatus.all.each {|x| return x.id if x.is_closed}
          status = IssueStatus.where("is_closed = ?", true)
          return status.first.id if !status.nil?
        end
      end

      module InstanceMethods

      end
    end
  end
end
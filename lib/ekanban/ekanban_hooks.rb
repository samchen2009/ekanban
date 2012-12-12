module EKanban
  module Hooks
    class ControllerIssuesEditBeforeSaveHook < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(context={})
      	debugger
        if context[:params] && context[:params][:issue]
   	      if User.current.allowed_to?(:assign_deliverable_to_issue, context[:issue].project)
          	puts "Yes"
          end
        end
        return ''
      end

      alias_method :controller_issues_new_before_save, :controller_issues_edit_before_save
    end
  end
end
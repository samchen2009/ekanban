require 'redmine'
require 'ekanban/ekanban_hooks'
require 'ekanban/redmine_patches'
require 'ekanban/issue_patch'
require 'ekanban/group_patch'
require 'ekanban/issue_status_patch'
require 'ekanban/journal_patch'
require 'ekanban/principal_patch'
require 'ekanban/project_patch'
require 'ekanban/role_patch'
require 'ekanban/user_patch'


Redmine::Plugin.register :ekanban do
  name 'Ekanban Plugin'
  author 'samchen2009@gmail.com'
  description 'This is a kanban plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/samchen2009/ekanban'
  author_url 'http://www.e-kaifa.com'

  requires_redmine :version_or_higher => '2.1.2'
  project_module :Kanban do
   permission :view_kanban, :kanbans => :index
  end
  menu :project_menu, :Kanban, {:controller=>'kanbans', :action => 'index'}, :caption => 'Kanbans', :after => :activity, :param => :project_id
  menu :admin_menu, :Kanban_States, {:controller=>'kanban_states', :action => 'setup'}, :caption => 'Kanban States'


  Rails.configuration.to_prepare do
    unless ProjectsHelper.included_modules.include?(EKanban::Patches::ProjectsHelperPatch)
        ProjectsHelper.send(:include, EKanban::Patches::ProjectsHelperPatch)
    end

    unless ProjectsController.included_modules.include? EKanban::Patches::ProjectsControllerPatch
      ProjectsController.send(:include, EKanban::Patches::ProjectsControllerPatch)
    end

    unless Issue.included_modules.include? EKanban::Patches::IssuePatch
      Issue.send(:include, EKanban::Patches::IssuePatch)
    end

    unless IssueStatus.included_modules.include? EKanban::Patches::IssueStatusPatch
      IssueStatus.send(:include, EKanban::Patches::IssueStatusPatch)
    end

    unless Project.included_modules.include? EKanban::Patches::ProjectPatch
      Project.send(:include, EKanban::Patches::ProjectPatch)
    end

    unless Group.included_modules.include? EKanban::Patches::GroupPatch
      Group.send(:include, EKanban::Patches::GroupPatch)
    end

    unless User.included_modules.include? EKanban::Patches::UserPatch
      User.send(:include, EKanban::Patches::UserPatch)
    end

    unless Principal.included_modules.include? EKanban::Patches::PrincipalPatch
      Principal.send(:include, EKanban::Patches::PrincipalPatch)
    end

    unless Journal.included_modules.include? EKanban::Patches::JournalPatch
      Journal.send(:include, EKanban::Patches::JournalPatch)
    end

    unless Role.included_modules.include? EKanban::Patches::RolePatch
      Role.send(:include, EKanban::Patches::RolePatch)
    end
  end
end



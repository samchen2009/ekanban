require 'redmine'
require 'ekanban/ekanban_hooks'
require 'ekanban/redmine_patches'

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
  end
end



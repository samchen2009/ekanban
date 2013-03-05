eKanban
===========

Thank you for your interest in eKanban.

eKanban is a redmine plugin to support Kanban - an agile software development method.

Please visit www.e-kaifa.com/projects/mybloh/kanbans to see the demo.

account: guest
password: redmine

INSTALLATION INSTRUCTIONS
-------------------------

Download the package from https://github.com/samchen2009/ekanban.
Now, this plugins only work (at least, only verified) on Redmine 2.1.x.

unpack it into #{RAILS_ROOT}/plugins

Name the unpacked folder 'AgileDwarf'

OR instead of downloading and unpacking

    cd $(RAILS_ROOT)/plugins
    git clone https://github.com/samchen2009/ekanban.git

In #{RAILS_ROOT} run the command
    
    bundle install
    rake redmine:plugins:migrate
  
Restart Redmine
 
Change settings for plugin via 

    Administration -> Setting -> Project -> Default enabled modules for new projects -> Check "Kanban"
    
    Administration -> Kanban States
  

ABOUT eKanban
-----------------

eKanban plugin implements the agile method - Kanban.

It adds the followings to redmine.

### Kanban Board

'Kanban Board' is a board to visualize the issue status of a tracker.
* Drag & Drop support for issue between different states.
* Double click to view issue(kanban card) status and history.
* Quickly filter issue(kanban card).
* Prioritising stories/issues with different color.
* Issue weekly report and other charts.
* Setup/Manage Kanban.
* Indicate user's wip and wip limit.

### Kanban State/Stages/Panes

* Kanban state is corresponding to a issue status.
* Kanban stage is corresponding to a period in project process, it may contain several kanban states.
* Kanban pane is a column in kanban board that corresponding to a kanban state.
* Relationship: Kanban board have several kanban stages, every kanban stages have at least one kanban panes, not every kanban state will be show in kanban board, for example, the 'closed' state.


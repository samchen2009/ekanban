eKanban
===========

Thank you for your interest in eKanban.

eKanban is a redmine plugin to support Kanban - an agile software development method.

You can visit www.e-kaifa.com/projects/mybloh/kanbans to see the demo.

account: guest
password: redmine

INSTALLATION INSTRUCTIONS
-------------------------

Download the package from https://github.com/samchen2009/ekanban.
Now, this plugins only work (at least, only verified) on Redmine 2.1.x.

unpack it into #{RAILS_ROOT}/plugins

Name the unpacked folder 'ekanban'

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

'Kanban Board' is a board to visualize the issues in a specific tracker.
* Drag & Drop issue between different states.
* Double click to view issue(kanban card) status and history.
* Quickly filter issue(kanban card).
* Prioritising stories/issues with different colors.
* Issue weekly report and various charts(TBD).
* Config/Manange Kanbans.
* Indicate user's wip and wip limit.

### Kanban State/Stage/Pane

* Kanban state is corresponding to a issue status.
* Kanban stage is a generic stage in project process, it contains one or more kanban states.
* Kanban pane is a column (corresponding to a kanban state) in kanban board that actually holds issues. 
* Relationship: Kanban board have several kanban stages, every kanban stages have at least one kanban panes, not all kanban states are shown in kanban board, the 'closed' state.

### WIP/WIP Limit
* WIP: work(issue) in progress. 
* WIP Limit: The max number of issue that a member, a group or a stage can work on at the same time. WIP Limit have 2 modes:
  * auto: WIP Limit is calculated (check the 'auto' in 'kanban pane' setup tab) automatically by system.
  * user: User define the value. For example, set "Backlog"'s wip_limit as 100.
* Only specific panes (have "in progress" checked in the 'kanban pane' setup tab) will consume WIP.



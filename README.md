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
Now, this plugins only work (at least, only verified) on Redmine 2.1.x, 2.2.x, 2.3.2.

unpack it into #{RAILS_ROOT}/plugins

Name the unpacked folder 'ekanban'

OR instead of downloading and unpacking

    cd $(RAILS_ROOT)/plugins
    git clone https://github.com/samchen2009/ekanban.git
    
Add "gem 'haml'" to your #{RAILS_ROOT}/Gemfile    

In #{RAILS_ROOT} run the command
        
    bundle install
    rake redmine:plugins:migrate RAILS_ENV=production

(or change production to whatever Rails environment you are using).

  
Restart Redmine

    Add a field "WIP limit" (format:integer) in 'Administrator' -> 'Custom fields' -> 'User'    
 
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
* Issue weekly report and various charts(TBD). - try redmine_charts2 plugin by others.
* Config/Manange Kanbans.
* Indicate user's WIP and WIP limit.

### Kanban State/Stage/Pane

* Kanban state is corresponding to an issue status.
* Kanban stage is a generic stage in project process, it consists of at least one state.
* Kanban pane is a column (corresponding to a kanban state) in kanban board that actually holds issues. 
* Kanban Workflow: the transitions between different kanban pane. 

### WIP/WIP Limit
* WIP: work(issue) in progress. 
* WIP Limit: The max number of issue that a member, a group or a stage can work on at the same time. WIP Limit have 2 modes:
  * auto: WIP Limit is calculated (check the 'auto' in 'kanban pane' setup tab) automatically by system.
  * user: User define the value. For example, set "Backlog"'s wip_limit as 100.
* Only specific panes (have "in progress" checked in the 'kanban pane' setup tab) will consume WIP.

USAGE
-----------------

### Setup Kanban States
  
1. Go to "Administrator" -> "Kanban States"

2. Select tab "Kanban Stages" and "New Kanban Stage", in www.e-kaifa.com, we have the following kanban stages created, **Backlog**, **Planed**, **Development**, **Test**, **Release**, **Closed**.

3. Select tab "Kanban State" and "New Kanban State", each kanban state should be designed to match the issue status accordingly. Given that Kanban is a "Pull" system, you should basically have 2 states - "In progress" and "Done" for stages that need to consume WIP. For example, in www.e-kaifa.com, we created 2 states: **In Progress** and **Solved** in **Development** stage.
    
4. Finally, to make the issue transition reflecting in the Kanban, select the 3rd tab to associate the issue status with kanban state.

 
### Create and Setup a Kanban

1. Go to "Project" -> "Kanban" and click "New Kanban". 

2. Select a "Tracker", which specify the scope of states may be used by this kanban. 

3. You can copy an "existing" kanban if any to simplify the setup process.

4. Back to the Kanban board and click "Setup" icon.

5. Select the tab **Pane**, and add the column to be shown in a Kanban.   
NOTE: You can drag and drop the row of pane to reorder its position(col) in the Kanban.  

6. In the "New Kanban Pane" page, you should specify
  * WIP_Limit: an number or 'auto'? Normally, you should select 'auto' for pane will consume resource.  
  * Role: who will work on this stage? This will affect the WIP/WIP_Limit calculation.  
  * Work In Progress?: Whether consume resource in the state? For instance, 'Backlog' pane should not be checked.  

7. Final step, select the tab "kanban workflow" to setup the Kanban workflow.


## Typical Kanban Workflow

You could visit www.e-kaifa.com/projects/3/kanbans/1/edit to view a typical kanban workflow for software development. 


LICENSE
-----------------

The MIT License (MIT) Copyright (c) 2012-2013 Shan Chen


//Ajax APIs

function getUserWipAndLimit(user_id){
  kanbanAjaxCall("get",
                   "/kanban_apis/user_wip_and_limit",{"user_id":user_id},
                   function(data,result){
                    if (result == 0){
                      $("#my-profile").data("user").wip_limit = data.wip_limit;
                      $("#my-profile").data("wip",data.wip);
                    }else{
                      return undefined;
                    }
                  });
}

function getKanbanStates(){
  kanbanAjaxCall("get",
                   "/kanban_apis/kanban_states",{"id":9999},
                   function(data,result){
                    if (result == 0){
                      $("#kanban-data").data("kanban_states",data);
                    }else{
                      return undefined;
                    }
                  });
}

function getKanbanStateIssueStatus(){
  kanbanAjaxCall("get",
                   "/kanban_apis/kanban_state_issue_status",{"id":0},
                   function(data,result){
                    if (result == 0){
                      $("#kanban-data").data("kanban_state_issue_status",data)
                    }
                  });
}

function getKanbanWorkflow(){
  kanbanAjaxCall("get",
                 "/kanban_apis/kanban_workflow",{"id":0},
                 function(data,result){
                  if (result == 0){
                    $("#kanban-data").data("kanban_workflow",data)
                  }
                });
}

function getIssueWorkflow(){
  kanbanAjaxCall("get",
                 "/kanban_apis/issue_workflow",{"id":0},
                 function(data,result){
                  if (result == 0){
                    $("#kanban-data").data("issue_workflow",data)
                  }
                });
}

function getIssueJournals(issue_id,callback){
  kanbanAjaxCall("get",
                 "/kanban_apis/issue_journals",{"issue_id":issue_id},
                 function(data,result){
                  if (result == 0){
                    return data;
                  }
                });
}

function kanbanAjaxCall(type,url,params,callback){
  $.ajax({
      type: type,
      url:  url,
      dataType: "json",
      data: params,
      cache: false,
      success: function(json){
        callback(json,0);
      },
      error: function (XMLHttpRequest, textStatus, errorThrown){
        callback(XMLHttpRequest,XMLHttpRequest.status);
      }
    });
}


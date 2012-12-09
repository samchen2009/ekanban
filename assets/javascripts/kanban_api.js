//Ajax APIs

function getUserWip(user_id){
  getKanbanAjaxCall("get",
                   "/kanban_apis/user_wip",{"id":user_id},
                   function(data,result){
                    if (result == 0){
                      return data;
                    }else{
                      return undefined;
                    }
                  }
  );
}


function getKanbanStateIssueStatus()
{
  getKanbanAjaxCall("get",
                   "/kanban_apis/kanban_state_issue_status",{"id":0},
                   function(data,result){
                    if (result == 0){
                      $(window).data("kanban_state_issue_status",data)
                    }
                  }
  );
}

function getKanbanWorkflow(){
  getKanbanAjaxCall("get",
                 "/kanban_apis/kanban_workflow",{"id":0},
                 function(data,result){
                  if (result == 0){
                    $(window).data("kanban_workflow",data)
                  }
                }
}

function getIssueWorkflow(){
  getKanbanAjaxCall("get",
                 "/kanban_apis/issue_workflow",{"id":0},
                 function(data,result){
                  if (result == 0){
                    $(window).data("issue_workflow",data)
                  }
                }
}

function getKanbanAjaxCall(type,url,params,callback){
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


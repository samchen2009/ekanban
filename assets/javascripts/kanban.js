/* On droppable accept is invoked */
function onDroppableAccept(){
    //alert("ssss")
    console.debug("ssss")
}

/* When user drop the draggable */
function onDroppableDrop(event,ui){
    //alert(arguments.callee.toString())
    console.debug("iiiiiiiiii")
}

function updateWip(wip,wip_limit,stage){
	$("wip_"+stage).html("<span class:wip-text> (" + wip + ":" +wip_limit +")");
}

/* Popup window */
function popupCard(fromPane,toPane,card,popup,event)
{
  initPopupCard(popup,card,event,fromPane,toPane);
  //$.blockUI({
  //  message: $("#popupWindow")
  //});
  var isModal = (event == "drop")? true : false;
  popup.dialog({
    autoOpen: true,
    //modal: isModal,
    width: "auto"
  });
}

/* Ajax call */
function updateCard(popup,card,sender,receiver){
}

function kanbanStateToIssueStatus(state_id)
{
  var issue_status_id = 9999;
  var t = $("#kanban-data").data("kanban_state_issue_status").kanban_state_issue_status;
  for (i = 0; i < t.length; i++){
    if (t[i].issue_status_kanban_state.kanban_state_id == state_id){
      issue_status_id = t[i].issue_status_kanban_state.issue_status_id;
      break;
    }
  }
  return issue_status_id;
}

function initPopupCard(popup,card,action,sender,receiver){
  if (action === "new"){
    popup.find("#popupWindowHeader").html("<p>New Issue </p>").show();
  }else{
    var issue_id = card.attr("id");
    popup.find("#popupWindowHeader").html("<a href='/issues/" + issue_id + "'>#" +  issue_id +"</a>" + ": " + card.find("#subject").val()).show();
    if (action === "edit"){
      popup.find("select#issue_status_id").val(card.find("#issue_status_id").val());
      popup.find("select#kanban_state_id").val(card.find("#kanban_state_id").val());
      // no move, set to 0 to skip update.
      popup.find("#kanban_pane_id").val(0);
    }else if (action == 'drop'){
      // Change the assignee to me
      var pane_id = receiver.attr("id").match(/\d+$/)[0];
      var state_id = receiver.attr("state_id")
      var status_id = kanbanStateToIssueStatus(state_id);
      popup.find("select#issue_status_id").val(status_id);
      popup.find("select#kanban_state_id").val(state_id);
      card.find("#assignee_id").val(myUserID());
      popup.find("#kanban_pane_id").val(pane_id);
      if (hasRole("developer")){
        card.find("#developer_id").val(myUserID());
      }
      if (hasRole("validater")){
        card.find("#verifier_id").val(myUserID());
      }
    }
    popup.find("select#assignee_id").val(card.find("#assignee_id").val());
    popup.find("select#developer_id").val(card.find("#developer_id").val());
    popup.find("select#verifier_id").val(card.find("#verifier_id").val());
    popup.find("#issue_id").val(issue_id);
    popup.find("textarea").val("").focus(1);
    popup.find("#indication").hide();
  }
}

function init_wip(kanban_id,json){
  var panes = json[0];
  var stages = json[1];
  if (typeof(panes[0]) == "undefined") return;
  //table = $("#kanban_" + panes[0].kanban_pane.kanban_id)
  table = $("#kanban_" + kanban_id);
  for (i=0; i<stages.length; i++){
    pane_id = panes[i].kanban_pane.id
    if (i > 0 && (stages[i].kanban_stage.id === stages[i-1].kanban_stage.id)){
      wip += $("#pane_"+pane_id).children(":visible").length;
    }else{
      wip = $("#pane_"+pane_id).children(":visible").length;
    }
    var wip_limit = panes[i].kanban_pane.wip_limit;
    table.find("#wip_"+ stages[i].kanban_stage.id).text("(" + wip + ":" +wip_limit +")");
    table.find("#wip_"+ stages[i].kanban_stage.id).data("wip",wip);
    table.find("#wip_"+ stages[i].kanban_stage.id).data("wip_limit",wip_limit);
    //store stage name in each pane's data.
    $("#pane_"+(i+1)).data("stage",stages[i].kanban_stage.name);
    $("#pane_"+(i+1)).data("stage_id",stages[i].kanban_stage.id);
  }
}

function updatePanesWip(sender, receiver){
   var stage_from = sender.data("stage_id");
   var stage_to   = receiver.data("stage_id");
   var table = sender.parents("table");

   if (stage_from != stage_to){
   	 var from_wip = table.find("#wip_"+stage_from).data("wip") - 1;
   	 var to_wip  = table.find("#wip_"+stage_to).data("wip") + 1;
   	 var from_wip_limit = table.find("#wip_"+stage_from).data("wip_limit");
   	 var to_wip_limit = table.find("#wip_"+stage_from).data("wip_limit");
   	 table.find("#wip_"+stage_from).text("(" + from_wip + ":" + from_wip_limit + ")");
     table.find("#wip_"+stage_to).text("(" + to_wip + ":" + to_wip_limit + ")");
     table.find("#wip_"+stage_from).data("wip",from_wip);
     table.find("#wip_"+stage_to).data("wip",to_wip);
     sender.data("wip",from_wip);
     receiver.data("wip",to_wip);
   }
}

//SETTING UP OUR POPUP
//0 means disabled; 1 means enabled;
function createPopupCard(card){
	$("#PopupWindowBody").html("<p> Comming soon </p>");
}


function kanbanStateToStage(state_id){
  stage_id = 9999;
  var t = $("#kanban-data").data("kanban_states").kanban_states;
  for (i = 0; i < t.length; i++){
    if (t[i].kanban_state.id == state_id){
      stage_id = t[i].kanban_state.stage_id;
      break;
    }
  }
  return stage_id;
}

function myLoginName(){
  return $("#loggedas a").text()
}

function projectID(){
  return $("#project-profile").data("project").project.id;
}

function myUserID(){
  return $("#my-profile").data("user").user.id;
}

function hasRole(role_name)
{
  roles = myRoles();
  for (i=0; i<roles.length;i++){
    if (roles[i].role.name.toLowerCase() == role_name.toLowerCase()){
      return true;
    }
  }
  return false;
}

function hasRoleId(role_id){
  roles = myRoles();
  for (i=0; i<roles.length; i++){
    if (roles[i].role.id == role_id){
      return true;
    }
  }
  return false;
}

function myRoles()
{
  return $("#my-profile").data("roles");
}

function kanbanPaneRole(pane_id){
  return $("pane_" + pane_id).attr("role_id");
}

function isValidKanbanTransition(from,to){
  t = $("#kanban-data").data("kanban_workflow").kanban_workflow;
  for (i = 0; i < t.length; i++){
    if (t[i].kanban_workflow.old_state_id == from && to == t[i].kanban_workflow.new_state_id){
      if (t[i].kanban_workflow.check_role){
        return hasRoleId(t[i].kanban_workflow.role_id);
      }
      return true;
    }
  }
  return false;
}

function isValidIssueTransition(from,to){

}

/* Input:
 *   1. Card -> user/group -> roles.
 *   2. From Pane
 *   3. To Pane
 *
 * Output:
 *   1. true or false
 *   2. error text
 *
 */
function cardIsAccepted(card,sender,receiver){
  var user_id   = card.find("#assignee_id").val();
  var status_id = card.find("#issue_status_id").val();
  table = sender.parents("table");

  var to_state = receiver.attr("state_id");
  var from_state = sender.attr("state_id");
  var to_stage = kanbanStateToStage(to_state);
  var from_stage = kanbanStateToStage(from_state);
  var to_wip = table.find("#wip_"+to_stage).data("wip");
  var to_wip_limit = table.find("#wip_"+to_stage).data("wip_limit");

  var pane_role = receiver.attr("role_id");

  if (to_stage === from_stage && assignee_changed == false){
    return {"success":true,"error":"In the same stage"};
  }
  /*
   * 1. non-wip pane -> wip pane.
   * 2. assignee changed in wip_pane.
   */
  if ((sender.attr("check_wip") == "false" && receiver.attr("check_wip") == "true") ||
      (card.find("#assignee_id").val() != myUserID() && receiver.attr("check_wip") == "true")){
    my_wip_limit = $("#my-profile").data("user").user.wip_limit;
    my_wip = $("#my-profile").data("wip").length;
    if (my_wip == my_wip_limit){
      return {"success":false,"error":"reach your wip_limit"}
    }
  }

  if (!isValidKanbanTransition(from_state,to_state)){
    return {"success":false,"error":"Invalid state transition"}
  }

  /* Check pane's WIPLimit */
  if (to_wip === to_wip_limit){
    return {"success":false, "error":"Exeed wip_limit"};
  }
  return {"success":true,"error":"OK"};
}
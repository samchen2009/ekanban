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
  renderPopupCard(popup,card,event,fromPane,toPane);
  var isModal = (event == "drop")? true : false;
  var w = (event == "drop")? "auto" : "1024px";
  var h = (event == "drop")? "auto" : "720px";
  popup.dialog({
    autoOpen: true,
    //modal: isModal,
    width: w,
    //height: h,
  });
}

/* Ajax call */
function updateCard(popup,card,sender,receiver){
}

function kanbanStateToIssueStatus(state_id){
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

function filterJournals(journals){
  prop_keys = ["priority_id", "fixed_version_id", "done_ratio"];

  for (i = journals.length; i > 0; i--){
    journal = journals[i-1];
    for (j = journal.details.length; j > 0; j--){
      detail = journal.details[j-1];
      if ($.inArray(detail.journal_detail.prop_key, prop_keys) == -1){
        console.debug()
        journal.details.splice(j-1,1);
      }
    }
    if (journal.details.length == 0 && journal.note == ""){
      journals.splice(i-1,1);
    }

  }
}

function spent_time(from,to){
  var msPerMin  = 60*1000;
  var msPerHour = 3600 * 1000;
  var msPerDay = 24*msPerHour;
  ms = new Date(to) - new Date(from);
  if (ms < msPerHour){
    str = Math.round(ms/msPerMin).toString() + "M";
  }else if (ms < msPerDay){
    str = Math.round(ms/msPerHour).toString() + "H";
  }else{
    str = Math.round(ms/msPerDay).toString() + "D";
  }
  return str;
}


function initCardJournals(card,sender,journals){
  filterJournals(journals.issue_journals);
  card.data("journals",journals);
  panes = $("#kanban-panes-data").data("panes");

  var json = [];
  for (i = panes.length; i > 0; i--){
    p = panes[i-1].kanban_pane;
    data = []
    var journal;
      for (j = 0; j < journals.card_journals.length; j++){
        journal = journals.card_journals[j];
        if (journal.pane_id == p.id){
          data.push({
            from: journal.from,
            to: journal.to,
            label: spent_time(journal.from, journal.to),
            customClass: "ganttGreen"});
        }
      }

      //current bar
      if (sender.attr("id").match(/\d+$/)[0]  == p.id){
        now = new Date();
        from = (journal === undefined)? new Date(card.find("#created_on").val()).toString() : journal.to;
        data.push({
          from: from,
          to: now.toString(),
          label: spent_time(from, now.toString()),
          customClass: "ganttRed"
        });
      }
      json.push({name:p.name, desc:"", values:data});
  }
  return json;
}

/*TODO: take UTC into account */
function renderCardHistory(popup,card,sender,journals)
{
  json = initCardJournals(card,sender, journals);

  var msPerHour = 3600*1000;
  var msPerDay = 24*msPerHour;
  var msPerWeek = 7*msPerDay;
  var msPerMonth = 30*msPerDay;

  started_at = new Date(card.find("#start_date").val());
  due_at = new Date(card.find("#due_date").val());
  today = new Date();
  created_at = new Date(card.find("#created_on").val());

  total_elapsed = today - created_at;
  if (total_elapsed < 1*msPerDay){
    scale = "hours";
  }else if (total_elapsed <= 12*msPerMonth){
    scale = "days";
  }else{
    scale = "weeks";
  }

  $("#card_history.gantt").gantt({
                source:json,
                navigate: "scroll",
                scale: scale,
                //maxScale: scales[1],
                //minScale: scales[0],
                itemsPerPage: 10,
                onItemClick: function(data) {
                    alert("Item clicked - show some details");
                },
                onAddClick: function(dt, rowId) {
                    alert("Empty space clicked - add an item!");
                },
                onRender: function() {
                    if (window.console && typeof console.log === "function") {
                        console.log("chart rendered");
                    }
                }
            });
  $(".kanban-card-history").show();
}


function renderPopupCard(popup,card,action,sender,receiver){
  if (action === "new"){
    popup.find("#card-form-header").html("<p>New Issue </p>").show();
  }else{
    var issue_id = card.attr("id");
    popup.find("#card_form_header").html("<a href='/issues/" + issue_id + "'>#" +  issue_id +"</a>" + ": " + card.find("#subject").val()).show();
    if (action === "edit"){
      popup.find("select#issue_status_id").val(card.find("#issue_status_id").val());
      popup.find("select#kanban_state_id").val(card.find("#kanban_state_id").val());
      // no move, set to 0 to skip update.
      popup.find("#kanban_pane_id").val(0);
      popup.find("#start_date_").val(card.find("#start_date").val());
      popup.find("#due_date_").val(card.find("#due_date").val());
      kanbanAjaxCall("get",
                 "/kanban_apis/kanban_card_journals",{"issue_id":issue_id},
                 function(data,result){
                  if (result == 0){
                    renderCardHistory(popup,card,sender,data)
                    //console.debug(data);
                  }
                });
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
      if (receiver.data("stage") == "Planed"){
        var today = new Date();
        var m = today.getMonth() + 1;
        var d = today.getDate();
        var y = today.getFullYear();
        var date = y + '/' + (m < 10? '0':'') + m + '/' + (d < 10 ? '0':'') + (d);
        popup.find("#start_date_").css("required",true);
        popup.find("#start_date_").val(date);
        popup.find("#due_date_").css("required",true);
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
    $("#pane_"+pane_id).data("stage",stages[i].kanban_stage.name);
    $("#pane_"+pane_id).data("stage_id",stages[i].kanban_stage.id);
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

  /* "Non-Member" and "Anonymous" is open to anybody */
  if (role_id == 0 || role_id == 1){
    return true;
  }

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

  if (to_stage === from_stage && card.find("#assignee_id").val() == myUserID()){
    return {"success":true,"error":"In the same stage"};
  }
  /*
   * 1. non-wip pane -> wip pane.
   * 2. assignee changed in wip_pane.
   */
  if ((sender.attr("check_wip") == "false" && receiver.attr("check_wip") == "true") ||
      (card.find("#assignee_id").val() != myUserID() && receiver.attr("check_wip") == "true")){
    my_wip_limit = $("#my-profile").data("user").wip_limit;
    my_wip = $("#my-profile").data("wip").length;
    if (my_wip >= my_wip_limit){
      return {"success":false,"error":"reach your wip_limit"}
    }
  }

  if (!isValidKanbanTransition(from_state,to_state)){
    return {"success":false,"error":"Invalid state transition"}
  }

  /* Check pane's WIPLimit */
  if (to_wip >= to_wip_limit){
    return {"success":false, "error":"Exeed wip_limit"};
  }
  return {"success":true,"error":"OK"};
}

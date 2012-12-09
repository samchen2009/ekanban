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

/* Check whether the card can be dropped in a new pane
 # event: over
 # ui.sender: the pane that card comes from.
 # ui.item: the dragged card.
*/
function cardIsAccepted(event, ui){
	console.debug("return true")
    return true;
}

function updateWip(wip,wip_limit,stage){
	$("wip_"+stage).html("<span class:wip-text> (" + wip + ":" +wip_limit +")");
}

/* Popup window */
function popupCard(fromPane,toPane,card,popup,event)
{
  initPopupCard(popup,card,event,toPane);
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
  var t = $(window).data("kanban_state_issue_status").kanban_state_issue_status;
  for (i = 0; i < t.length; i++){
    if (t[i].issue_status_kanban_state.kanban_state_id == state_id){
      issue_status_id = t[i].issue_status_kanban_state.issue_status_id;
      break;
    }
  }
  return issue_status_id;
}

function initPopupCard(popup,card,action,receiver){
  if (action === "new"){
    popup.find("#popupWindowHeader").html("<p>New Issue </p>").show();
    popup.find("issue_id").focus(1);
  }else{
    var issue_id = card.attr("id");
    popup.find("#popupWindowHeader").html("<a href='/issues/" + issue_id + "'>#" +  issue_id +"</a>" + ": " + card.find("#subject").val()).show();
    if (action === "edit"){
      popup.find("select#issue_status_id").val(card.find("#issue_status_id").val());
      popup.find("select#kanban_state_id").val(card.find("#kanban_state_id").val());
    }else if (action == 'drop'){
      var pane_id = receiver.attr("id").match(/\d+$/)[0];
      var status_id = kanbanStateToIssueStatus(pane_id);
      popup.find("select#issue_status_id").val(status_id);
      popup.find("select#kanban_state_id").val(pane_id); 
    }
    popup.find("select#assignee_id").val(card.find("#assignee_id").val());
    popup.find("select#developer_id").val(card.find("#developer_id").val());
    popup.find("select#verifier_id").val(card.find("#verifier_id").val());
    popup.find("textarea").val("").focus(1);
  }
}

function init_wip(json){
	for (i=0; i<json[1].length; i++){
        if (json[1][i] === json[1][i-1])
           wip += $("#pane_"+(i+1)).children(":visible").length;
         else{
           wip = $("#pane_"+(i+1)).children(":visible").length;
         }
         var wip_limit = json[0][i].kanban_pane.wip_limit;
         $("#wip_"+ json[1][i]).text("(" + wip + ":" +wip_limit +")");
         $("#wip_"+ json[1][i]).data("wip",wip);
         $("#wip_"+ json[1][i]).data("wip_limit",wip_limit);
         //store stage name in each pane's data.
         $("#pane_"+(i+1)).data("stage",json[1][i]);
    }
}

function updatePanesWip(sender, receiver){
   var stage_from = sender.data("stage");
   var stage_to   = receiver.data("stage");
   if (stage_from != stage_to){
   	 var from_wip = $("#wip_"+stage_from).data("wip") - 1;
   	 var to_wip  = $("#wip_"+stage_to).data("wip") + 1;
   	 var from_wip_limit = $("#wip_"+stage_from).data("wip_limit");
   	 var to_wip_limit = $("#wip_"+stage_from).data("wip_limit");
   	 $("#wip_"+stage_from).text("(" + from_wip + ":" + from_wip_limit + ")");
     $("#wip_"+stage_to).text("(" + to_wip + ":" + to_wip_limit + ")");
     $("#wip_"+stage_from).data("wip",from_wip);
     $("#wip_"+stage_to).data("wip",to_wip);
     sender.data("wip",from_wip);
     receiver.data("wip",to_wip);
   }
}

//SETTING UP OUR POPUP
//0 means disabled; 1 means enabled;
function createPopupCard(card){
	$("#PopupWindowBody").html("<p> Comming soon </p>");
}

//loading popup with jQuery magic!
function loadPopup(el){
	//loads popup only if it is disabled
	if (!el.hasClass("popuped")){
		el.css({
			"opacity": "1"
		});
	}
	//$("#backgroundPopup").fadeIn("slow");
	el.fadeIn("slow");
	el.addClass("popuped");
}

//disabling popup with jQuery magic!
function disablePopup(el){
	//disables popup only if it is enabled
	if(el.hasClass("popuped")){
		//$("#backgroundPopup").fadeOut("slow");
    el.removeClass("popuped");
    $.unblockUI();
		el.fadeOut("slow");
	}
}

//centering popup
function centerPopup(el){
	//request data for centering
	var windowWidth = document.documentElement.clientWidth;
	var windowHeight = document.documentElement.clientHeight;
	var popupHeight = el.height();
	var popupWidth = el.width();
	//centering
	el.css({
		"position": "absolute",
		"top": windowHeight/2-popupHeight/2,
		"left": windowWidth/2-popupWidth/2
	});
}

/* 1. Kanban workflow
 * 2. Issue workflow
 * 3. WIP limit reach?
 * 4. User's wip limit reach?
 */
function checkKanbanFlow(){

}
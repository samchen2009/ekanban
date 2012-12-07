/* On droppable accept is invoked */
function onDroppableAccept(){
    //alert("ssss")
    console.debug("ssss")
}

/* When user drop the draggable */
function onDroppableDrop(event,ui){
    //alert(arguments.callee.toString());
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

function popupCard(origin,current,action,pane)
{
  initPopupCard(current,origin,action,pane);
  centerPopup(current);
  loadPopup(current);
}

function updateCard(sender,card,receiver){

}

function initPopupCard(current,origin,action){
  if (action === "new"){
    current.find("#popupWindowHeader").html("<p>New Issue </p>").show();
    current.find("issue_id").focus(1);
  }else if (action === "edit"){
    var issue_id = origin.attr("id");
    current.find("#popupWindowHeader").html("<a href='/issues/" + issue_id + "'>#" +  issue_id +"</a>" + ": " + origin.find("#subject").val()).show();
    current.find("select#issue_status_id").val(origin.find("#issue_status_id").val());
    current.find("select#kanban_state_id").val(origin.find("#kanban_state_id").val());
    current.find("select#assignee_id").val(origin.find("#assignee_id").val());
    current.find("select#developer_id").val(origin.find("#developer_id").val());
    current.find("select#verifier_id").val(origin.find("#verifier_id").val());
    current.find("textarea").val("").focus(1);
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

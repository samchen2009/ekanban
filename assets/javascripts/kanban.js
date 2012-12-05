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


function updateCard(sender,card,receiver){

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
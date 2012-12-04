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
    console.debug(ui.sender);
    console.debug(ui.item);
    console.debug($(this));
    return false;
}

function updateCard(){}

function updatePane(){}
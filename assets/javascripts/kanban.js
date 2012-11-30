$(function() {
    $( ".kanban-pane" ).sortable({
        connectWith: ".kanban-pane"
    });

    $( ".kanban-card" ).addClass( "ui-helper-clearfix ui-corner-all" )
        .find( ".card-header" )
            .addClass( "ui-widget-header ui-corner-all" )
            .prepend( "<span class='ui-icon-minusthick'></span>")
            .end()
        .find( ".card-content" );

    $( ".card-header .ui-icon" ).click(function() {
        $( this ).toggleClass( "ui-icon-minusthick" ).toggleClass( "ui-icon-plusthick" );
        $( this ).parents( ".kanban-card:first" ).find( ".card-content" ).toggle();
    });
    $( ".kanban-pane" ).disableSelection();
});
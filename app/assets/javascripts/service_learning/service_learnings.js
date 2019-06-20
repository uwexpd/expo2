(function() {
    var view_state = "";

})()

$(document).on("click", "a[data-view-display]", function(){	
    
    var view = $(this).attr('data-view-display');
    var grids = $("div.col.s4").not(".selected_position");
    var lists = $("ul.collection").not(".selected_position");
    var show_filled = $('#position-filled :checkbox').prop('checked');

    if (view == 'grid'){        
        grids.show(); lists.hide();
        if (!show_filled){
            $("div.col.s4 .filled").each( function(i, obj){
                toggle_card(obj, show_filled);
            })            
        }
    }else if(view == 'list'){
        grids.hide(); lists.show();
        if (!show_filled){
            $("ul.collection .filled").each( function(i, obj){
                toggle_card(obj, show_filled);
            })
        }
    }
    view_state = view;
});

$(document).on("change", "#position-filled :checkbox", function() {    
	var show_filled = $('#position-filled :checkbox').prop('checked');        
    view_state= (typeof view_state == "undefined") ? "grid" : view_state;

    if (view_state == 'grid') {
        $("div.col.s4 .filled").each( function(i, obj){
            toggle_card(obj, show_filled);
        })
    }else{
        $("ul.collection .filled").each( function(i, obj){
            toggle_card(obj, show_filled);
        })
    }
    // var input = $("<input>").attr("type", "hidden").attr("name", "show_position_filled").val($('#position-filled :checkbox').prop('checked'));	
    // $("#position-filled").append(input).submit();
});

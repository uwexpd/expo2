// Initialization for materializecss javascript components
$(document).ready(function(){
    $('.tabs').tabs();
  });
// End

// Alert close button
$(document).on('page:change', function () {
  $('.alert').append('<button class="waves-effect btn-flat close"><i class="material-icons">close</i></button>');

  $('body').on('click', '.alert .close', function() {
    $(this).parent().fadeOut("slow", function() {
        $(this).remove();
    });
  });
});

// End

$(document).on("click", "a[data-link-toggle]", function(){ 
   var obj = $(this).attr('data-link-toggle');
   link_toggle(obj);
});

function toggle_card(obj, display){
    if (display) {
        $(obj).parent().show();
    }else{
        $(obj).parent().hide();
    }
}

function link_toggle(obj){
    $(obj).toggle();
}
$(document).on("click", "input[data-link-toggle]", function(){ 
   var obj = $(this).attr('data-link-toggle');
   link_toggle(obj);
});

$(document).on("click", "a[data-link-toggle]", function(){ 
   var obj = $(this).attr('data-link-toggle');
   link_toggle(obj);
});

function link_toggle(obj){
    $(obj).toggle();
}
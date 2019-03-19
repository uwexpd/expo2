// Append a button after action_items that will toggle the sidebar’s visibility. On page load, we are not hiding the sidebar if filters are in use. https://medium.com/@mekdigital/activeadmin-add-a-button-toggle-the-sidebars-visibility-to-save-real-restate-708d89cb5972
$(document).ready(function(){
  // epon is the class name for sidebar that is open/showing. Just a class name that won't clash :) 
  $('div.action_items').append('<span class="action_item"><a id="toggle_filters" href="#" class=\'epon\'>Sidebar</a></span>')
  // when we request a filtered collection, we won't hide the sidebar
  // if(!window.location.search.includes('Filter')){ $('div#sidebar').hide(); $('a#toggle_filters').removeClass('epon') }
  $('a#toggle_filters').click(function(){ $('div#sidebar').toggle(); $(this).toggleClass('epon') })
})


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
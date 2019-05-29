var admin = {

  init: function(){
    admin.set_admin_selectable_events();
  },

  set_admin_selectable_events: function(){    
    $("select.admin-selectable").live("change", function(e){
      var path        = $( e.currentTarget ).attr("data-path");
      var model       = $( e.currentTarget ).attr("data-model");
      var attr        = $( e.currentTarget ).attr("data-attr");
      var resource_id = $( e.currentTarget ).attr("data-resource-id");
      var val         = $( e.currentTarget ).val();

      val = $.trim(val)

      var payload = {}
      var payload = {}
      payload[model] = {};
      payload[model][attr] = val;      

      $.ajax({
           url: "/expo/admin/"+path+"/"+resource_id, 
           type: 'PUT',
           data: payload,
           dataType: 'json',
           success: function(response) {
             alert("Successfully updated the " + attr + "!");
           },
           error: function(request, error){             
             alert("Sorry, something went wrong!");
           }
        });      
      
    });
  }
}

$( document ).ready(function() {
  admin.init();
});
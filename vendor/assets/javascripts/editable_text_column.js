var admin = {

  init: function(){
    admin.set_admin_editable_events();
  },

  set_admin_editable_events: function(){
    $(".admin-editable").keypress(function(e){
      if ( e.keyCode==27 )
        $( e.currentTarget ).hide();

      if ( e.keyCode==13 ){        
        var path        = $( e.currentTarget ).attr("data-path");
        var model       = $( e.currentTarget ).attr("data-model");
        var attr        = $( e.currentTarget ).attr("data-attr");
        var required    = $( e.currentTarget ).attr("data-required");
        var resource_id = $( e.currentTarget ).attr("data-resource-id");
        var val         = $( e.currentTarget ).val();

        val = $.trim(val)
        if (val.length==0){
          if (required==="true"){
            alert("The " + attr + " can not be blank.");
            return false;
          }else{
            val = '';
          }          
        }

        $("div#"+$( e.currentTarget ).attr("id")).html(val);
        $( e.currentTarget ).hide();

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

      }
    });

    $(".admin-editable").blur(function(e){
      $( e.currentTarget ).hide();
    });
  },

  editable_text_column_do: function(el){

    var input = "input#"+$(el).attr("id")
    $(input).width( $(el).width()+4 ).height( $(el).height()+4 );
    $(input).css({top: ( $(el).offset().top-2 ), left: ( $(el).offset().left-2 ), position:'absolute'});

    // Decode all HTML entities with textarea element
    // https://stackoverflow.com/questions/3700326/decode-amp-back-to-in-javascript
    var textarea = document.createElement('textarea');
    textarea.innerHTML = $.trim( $(el).html() );
    val = textarea.value;
    if (val=="&nbsp;")
      val = "";
      
// console.log("Debug val=>" + val);  
    $(input).val( val );
    $(input).show();
    $(input).focus();
  }
}

$( document ).ready(function() {
  admin.init();
});
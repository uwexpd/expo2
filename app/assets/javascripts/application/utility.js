$(document).ready(function(){
  // Alert close
  $('.alert').not('.no_close').append('<button class="waves-effect btn-flat close"><i class="material-icons">close</i></button>');

  $('body').on('click', '.alert .close', function() {
    $(this).parent().fadeOut("slow", function() {
        $(this).remove();
    });
  });
  // End
});

 // Turbolinks fix: 
 // Refer to: https://stackoverflow.com/questions/18770517/rails-4-how-to-use-document-ready-with-turbo-links
 // https://codefor.life/turbolinks-5-rails-5-not-that-bad/
$(document).on('turbolinks:load', function() {
  // Initialization for materializecss javascript components
  $('.tabs').tabs();
  $('.datepicker').datepicker();
  $('select.material').formSelect();
  // End
});

$(document).on("click", "a[data-link-toggle]", function(){ 
  var obj = $(this).attr('data-link-toggle');
  link_toggle(obj);
});

function link_toggle(obj){
  $(obj).toggle();
}

function toggle_card(obj, display){
  if (display) {
      $(obj).parent().show();
  }else{
      $(obj).parent().hide();
  }
}


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
  // Materializecss javascript components initialization
  $('.tabs').tabs();  
  $('.datepicker').datepicker();
  $('.timepicker').timepicker();
  $('.collapsible').collapsible();
  $('select.material').formSelect();
  $('.input-field .charcounter').characterCounter();
  // End materializecss javascript initialization
  
  M.updateTextFields(); // Materializecss: Prefilling Text Inputs

  // Check materialize-textarea if needed to apply AutoResize method
  for (let i=0; i < $('.materialize-textarea').length; i++) {
    
    var element_id = $('.materialize-textarea')[i]['id']

    if ($.trim($('#' + element_id).val()).length > 0) {
      M.textareaAutoResize($('#'+ element_id));
    }      
  }


  //[TODO] Input filed and textarea word count
  // $('.input-field .wordcounter').keyup(function(){

  //     var textTrim = $('textarea').val();

  // });


  // initiate config of tinymce
  tinymce.init({
      selector: 'textarea.tinymce',
      // https://stackoverflow.com/questions/60834085/how-to-make-textarea-filed-mandatory-when-ive-applied-tinymce/66032994#66032994
      setup: function (editor) {
        editor.on('change', function () {
            tinymce.triggerSave();
            checkSubmit();
        });
      },
      plugins: 'advlist autolink lists link image charmap preview anchor searchreplace visualblocks code fullscreen searchreplace wordcount insertdatetime media table autoresize',
      toolbar: 'undo redo | cut copy paste searchreplace | italic subscript superscript charmap | preview hr spellchecker removeformat',      
      menubar: false,
      paste_merge_formats: true,
      browser_spellcheck: true
  });

  // check tinymce if empty before submit for long response question
  if ($(".tinymce_error").length){
    $(".tinymce_error").hide();
  }

  $(document).on('click', 'input[type=submit]', checkSubmit);
  function checkSubmit() {
    if ($('textarea.tinymce').length && $('textarea.tinymce').val().trim().length <= 0) {
      $('.tinymce_error').show();
      $('.tinymce_error').html('Please fill out content in the input box above');
      return false;
    }
    else{        
      $('.tinymce_error').hide();
      $('.tinymce_error').html('');   
    }
  }
  

}); // end of turbolinks:load

$(document).on("click", "a[data-link-toggle]", function(){ 
  var obj=$(this).attr('data-link-toggle');
  if (Object.keys(obj).length > 0){
      $(obj).toggle(400);
   }
});

function toggle_card(obj, display){
  if (display) {
      $(obj).parent().show();
  }else{
      $(obj).parent().hide();
  }
}




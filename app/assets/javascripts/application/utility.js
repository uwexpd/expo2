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
    
    let element_id = $('.materialize-textarea')[i]['id']

    if ($.trim($('#' + element_id).val()).length > 0) {
      M.textareaAutoResize($('#'+ element_id));
    }      
  }

  //Input textarea word count
  for (let i=0; i < $('.materialize-textarea.wordcounter').length; i++) {

    let element_id = $('.materialize-textarea')[i]['id']
    let element = $('#' + element_id)

    element.keyup(function(){

        let text_trim = $.trim(element.val());
        let word_limit = element.data("limit");

        if (text_trim.length > 0) {
          //finds a white space character and replaces it with a single space then splits it to create an array of words
          let words = text_trim.replace(/\s+/gi, ' ').split(' ');
          $('label[for=' + element_id + ']').next().text( words.length +' / '+ word_limit + ' words');
        }else {
          $('label[for=' + element_id + ']').next().text( '0 / '+ word_limit + ' words');
        }
    });
  }

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
    $('textarea.tinymce').each( function(index, element){      
      if ($(this).length && $(this).val().trim().length <= 0) {        
        $(this).next().next().show();
        $(this).next().next().html('Please fill out content in the input box above');
        return false;
      }
      else
      {        
        $(this).next().next().hide();
        $(this).next().next().html('');        
      }
    });
      
  }
  
  $(".select2").select2({
      width: 'resolve'
    });

  $(".select2.minimum_input").select2({    
      placeholder: 'Start entering characters',
      minimumInputLength: 2    
    });

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




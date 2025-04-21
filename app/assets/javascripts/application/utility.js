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
$(document).on('turbolinks:load', function() {
  // Materializecss javascript components initialization
  $('.tabs').tabs();
  $('.modal').modal();
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
      plugins: 'paste advlist autolink lists link image charmap preview anchor searchreplace visualblocks code fullscreen searchreplace wordcount insertdatetime media table autoresize',
      toolbar: 'undo redo | cut copy paste searchreplace | italic subscript superscript charmap | preview hr spellchecker removeformat',
      menubar: false,
      paste_as_text: true,
      browser_spellcheck: true,
      // https://stackoverflow.com/questions/60834085/how-to-make-textarea-filed-mandatory-when-ive-applied-tinymce/66032994#66032994
      setup: function (editor) {
        editor.on('change', function () {
            tinymce.triggerSave();
            checkSubmit();
        });
      }
  });

  // check tinymce if empty before submit for long response question
  if ($(".tinymce_error").length){
    $(".tinymce_error").hide();
  }

  $(document).on('click', 'input[type=submit]', checkSubmit);
  function checkSubmit() {
    let isValid = true; // Track if form is valid

    $('textarea.tinymce').each(function () {
      let $textarea = $(this);
      let content = tinymce.get($textarea.attr("id")).getContent({ format: 'text' }).trim();
      let maxLength = $textarea.data("length"); // Read max length from `data-length`
      let errorElement = $textarea.next().next(); // Error message div

      // If TinyMCE is empty, show error
      if (content.length <= 0) {
        errorElement.show().html('Please fill out content in the input box above.');
        isValid = false;
      } 
      // If maxLength exists and content exceeds limit, show error
      // else if (maxLength && content.length > maxLength) {
      //   errorElement.show().html(`Your input exceeds the allowed ${maxLength} characters. Please shorten your text.`);
      //   isValid = false;
      // }
      // If valid, hide error message
      else {
        errorElement.hide().html('');
      }
    });

    if (!isValid) {
      event.preventDefault(); // Prevent form submission if validation fails
    }
    // $('textarea.tinymce').each( function(index, element){
    //   if ($(this).length && $(this).val().trim().length <= 0) {
    //     $(this).next().next().show();
    //     $(this).next().next().html('Please fill out content in the input box above');
    //     return false;
    //   }
    //   else
    //   {
    //     $(this).next().next().hide();
    //     $(this).next().next().html('');
    //   }
    // });

  }
  
  $(".select2").select2({
      width: 'resolve'
    });

  $(".select2.minimum_input").select2({
      placeholder: 'Start entering characters',
      minimumInputLength: 2    
    });

  $(document).on("click", "a[data-link-toggle]", function(){
    var obj=$(this).attr('data-link-toggle');
    if (Object.keys(obj).length > 0){
        $(obj).toggle(400);
     }
  });

  $(document).ready(function() {
     $('input[data-checkbox]').change(function() {
        if ($(this).prop('checked')) {
          // Uncheck the other checkboxes
          var checkboxes = $(this).attr('data-checkbox').split(' ');
          $.each(checkboxes, function(index, checkbox){
            $('.'+ checkbox).prop('checked', false);
          });
        }
     });
  });

  $(document).on('click', '.show-more-link', function(e) {
    e.preventDefault();
    var $link = $(this);
    var fullText = $link.data('full-text');
    // console.log("Debug full text => ", fullText)
        
    // Replace truncated text with full text
    $('#reviewer_welcome').html(fullText);
    
  });

  // Adjust font size for reviewer interface [TODO] maybe expand to application wide
  $(document).ready(function() {    
    
    $('#increase-font').click(function() {
      var currentSize = parseInt($('#application_review').css('font-size'));
      $('#application_review').css('font-size', (currentSize + 2) + 'px');
    });

    $('#decrease-font').click(function() {
      var currentSize = parseInt($('#application_review').css('font-size'));
      $('#application_review').css('font-size', (currentSize - 2) + 'px');
    });
  });


  // Jquery UI sortable function in moderator interface [TODO] maybe expand to application wide
  $(document).ready(function() {
      var offeringId = $("#session_apps").data("offering-id"); 

      $(".sortable").sortable({
        handle: ".sort-handle", // Enables dragging only from the handle
        axis: "y", // Restricts movement to vertical axis
        update: function(event, ui) {
          var sortedIDs = $(".sortable").sortable("toArray", { attribute: "id" });
          var sortedData = sortedIDs.map(id => id.replace("app_", "")); // Extract numeric IDs

          $.ajax({
            type: "PATCH",
            url: "/expo/moderator/" + offeringId + "/sort_session_apps",  // Include offering ID in URL
            data: { session_apps: sortedData },
            headers: {
              'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
            },
            success: function(response) {
              $("#sorting-status").text("Order saved!").addClass("uw_green");;
              // console.log("Sorting updated successfully.");
            },
            error: function(xhr, status, error) {
              $("#sorting-status").text("Error saving order.").addClass("red_color");;
              console.error("Error updating sort order: " + error);
            }
          });
        }
      });
  });

  // In apply radio_logic_toggle page
  $(document).on("change", ".toggle-invisible", function () {
    let nextPageId = $(this).data("next-page-id");

    // Reset all hidden fields
    $('input[type=hidden][id^="hidden_invisible_"]').val('true');
    
    // Set the corresponding hidden field to false for the selected option
    if ($(this).is(':checked')) {
      $('#hidden_invisible_' + nextPageId).val('false');
    }
  });

}); // end of turbolinks:load

// for community_engaged toogle filled positions
function toggle_card(obj, display){
    if (display) {
        $(obj).parent().show();
    }else{
        $(obj).parent().hide();
    }
}
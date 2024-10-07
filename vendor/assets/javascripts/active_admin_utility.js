// Init tinyMCE
// tinyMCE.baseURL = '/expo/assets/tinymce/';

function initializeSelect2() {    
     $(".select2").select2({
         width: '100%'
     });

     $(".select2.minimum_input").select2({    
         placeholder: 'Start entering characters',
         minimumInputLength: 2
     });
}

$(function() {
   tinymce.init({
      selector: '.tinymce',
      plugins: 'advlist autolink lists link image charmap preview anchor searchreplace visualblocks code fullscreen searchreplace wordcount insertdatetime media table autoresize',
      toolbar: 'insertfile undo redo | cut copy paste searchreplace | styleselect forecolor backcolor | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link unlink anchor image media | table insertdatetime subscript superscript charmap preview code | hr spellchecker removeformat',
      menubar: false,
      paste_merge_formats: true,
      browser_spellcheck: true
   });

   // Enable chosen js
   $(".chosen-select").chosen({
      allow_single_deselect: true,
      no_results_text: 'No results matched'
   });

   // Append a button after action_items that will toggle the sidebar’s visibility. On page load, we are not hiding the sidebar if filters are in use. https://medium.com/@mekdigital/activeadmin-add-a-button-toggle-the-sidebars-visibility-to-save-real-restate-708d89cb5972
   // epon is the class name for sidebar that is open/showing. Just a class name that won't clash :)
   $('div.action_items').append('<span class="action_item"><a id="toggle_filters" href="#" class=\'epon\'><i class="mi md-16 sub_align">view_sidebar</i> Sidebar</a></span>')
   // when we request a filtered collection, we won't hide the sidebar
   // if(!window.location.search.includes('Filter')){ $('div#sidebar').hide(); $('a#toggle_filters').removeClass('epon') }
   if ($('div#sidebar').length == 0){$('a#toggle_filters').hide();}
   $('a#toggle_filters').click(function(){ $('div#sidebar').toggle(); $(this).toggleClass('epon') })
   
    // Initial page load
    initializeSelect2();

    // Select the reorderable column header (first column) with class 'reorder-handle-col'
    $('.aa-reorderable th.reorder-handle-col').text('Reorder');

    // Display user avatar picture
    var userAvatarLink = $('#user_avatar a');
  
    if (userAvatarLink.length) {       
       var avatarUrl = userAvatarLink.attr('href');       
       $('#utility_nav').css({
         'background': 'url(' + avatarUrl + ') no-repeat center center',
         'background-size': '40px',
         'border-radius': '50%'
       });
     }
    
});

$(document).on("change", ".toggleable", function(){
   let obj=$(this).attr('data-select-toggle');
   if (Object.keys(obj).length > 0){
      $(obj).show(400);
   }
});

$(document).on("click", "input[data-link-toggle]", function(){
   let obj=$(this).attr('data-link-toggle');
   if (Object.keys(obj).length > 0){
      $(obj).toggle(400);
   }
});

$(document).on("click", "a[data-link-toggle]", function(){ 
   let obj=$(this).attr('data-link-toggle');
   if (Object.keys(obj).length > 0){
      $(obj).toggle(400);
   }
});

$(document).on("click", "a[data-link-show]", function(){
   let obj=$(this).attr('data-link-show');
   if (Object.keys(obj).length > 0){
      $(obj).show();
   }
});

$(document).on("click", "a[data-link-hide]", function(){
   let obj=$(this).attr('data-link-hide');
   if (Object.keys(obj).length > 0){
      $(obj).hide();
   }
});

$(document).on("click", "a[data-field-id]", function(){
   let field_id = $(this).attr('data-field-id');
   let insert_text = $(this).attr('data-insert-text');
   insertAtCursor($('#'+field_id), insert_text);
});

$(document).on("click", "a[data-insert-text-tinymce]", function(){
   let tinymce_instance = tinymce.get($(this).attr('data-insert-text-tinymce'));
   let insert_text = $(this).attr('data-insert-text');
   tinymce_instance.execCommand('mceInsertContent', true, insert_text)
});

$(document).on("change", ".select_all", function(){   
   let css_class_parts = $(this).attr('class').split(/\s+/);
   // console.log("css_class_parts=>", css_class_parts);
   let checkbox_class = css_class_parts[0];
   let status = css_class_parts[1];
   // console.log("Debug => ", checkbox_class);
   // console.log("Debug => ", status);
   
   if (status == 'select_all'){
      $('.' + checkbox_class).prop('checked', this.checked);

   }else{
      $('.' + checkbox_class + '.' + status).prop('checked', $(this).prop('checked'));
   }

});
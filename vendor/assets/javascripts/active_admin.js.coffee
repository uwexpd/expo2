#= require active_admin/base
#= require tinymce

`$(document).ready(function() {
  tinyMCE.init({
     selector: '.tinymce',
     theme: 'modern',
	 menubar: false,
	 paste_merge_formats: true

   });
});`
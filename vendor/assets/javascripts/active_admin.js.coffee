#= require active_admin/base
#= require active_material
#= require tinymce
#= require chosen-jquery

tinyMCE.baseURL = '/expo/assets/tinymce/';

`$(document).ready(function() {
  tinyMCE.init({
     selector: '.tinymce',
     theme: 'modern',	 
	 plugins: [
	    'advlist autolink lists link image charmap print preview anchor',
	    'searchreplace visualblocks code fullscreen searchreplace wordcount',
	    'insertdatetime media table contextmenu paste textcolor colorpicker'
	 ],
	 toolbar: 'insertfile undo redo | cut copy paste searchreplace | styleselect forecolor backcolor | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link unlink anchor image media | table insertdatetime charmap preview code | hr spellchecker removeformat',	 
	 menubar: false,
	 paste_merge_formats: true,
	 browser_spellcheck: true	 	

   });
});`

$ ->
  # enable chosen js
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
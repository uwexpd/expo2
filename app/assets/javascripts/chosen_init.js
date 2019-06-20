// Fix: https://stackoverflow.com/questions/37797741/rails-5-turbolinks-5-some-js-not-loaded-on-page-render
// enable chosen js
$(document).on('turbolinks:load', function() {
    $(".chosen-select").chosen({
    	allow_single_deselect: true,
    	no_results_text: 'No results matched',
    	width: '100%'
    });
});

// Fix browser back button duplicated: https://github.com/turbolinks/turbolinks/issues/106
document.addEventListener("turbolinks:before-cache", function() {
    $('.chosen-select').chosen('destroy');
})
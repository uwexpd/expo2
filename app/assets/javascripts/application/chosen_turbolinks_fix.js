// Fix: https://stackoverflow.com/questions/37797741/rails-5-turbolinks-5-some-js-not-loaded-on-page-render
$(document).on('turbolinks:load', function() {
  $('#screen-selection').chosen({
    width: '100%'
  })
})
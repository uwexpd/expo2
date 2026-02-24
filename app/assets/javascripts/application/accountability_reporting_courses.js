$(document).on("ajax:beforeSend", ".mass-add-form", function (event) {
  var $form = $(this);
  var hash  = $form.data("abbrev-hash");

  var $select = $("#activity_type_id_" + hash);
  var $error  = $("#error_" + hash);

  // reset state
  $error.text("");
  $select.removeClass("fieldWithErrors");

  if (!$select.val()) {
    $error.text("Please choose an activity type.");
    $select.addClass("fieldWithErrors");

    event.preventDefault(); // stop AJAX submit
    return false;
  }
});
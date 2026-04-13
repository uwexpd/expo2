(function () {
  function wireStudentLookup() {
    var $field = $("#student_id");
    if ($field.length === 0) return;

    var url = $field.data("lookupUrl") || $field.attr("data-lookup-url");
    if (!url) return;

    function doLookup() {
      var val = $.trim($field.val());
      if (val.length === 0) return;

      $("#student_id_indicator").show();

      $.ajax({
        url: url,
        method: "GET",
        dataType: "script", // runs student_search.js.erb
        data: { student_id: val },
        complete: function () {
          $("#student_id_indicator").hide();
        }
      });
    }

    // Prevent double-binding with Turbolinks
    $field.off(".studentLookup");

    // Trigger when leaving the input box
    $field.on("blur.studentLookup", doLookup);

    // Trigger when pressing Enter
    $field.on("keydown.studentLookup", function (e) {
      if (e.key === "Enter" || e.keyCode === 13) {
        e.preventDefault();
        doLookup();
        $field.blur(); // optional: also forces "leave input box" behavior
      }
    });
  }

  $(document).on("turbolinks:load", wireStudentLookup);
})();
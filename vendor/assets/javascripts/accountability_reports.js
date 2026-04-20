// (function($) {
//   function statusUrlFor(template, id) {
//     return template.replace(":id", id);
//   }

//   function pollOne(template, id) {
//     var flagName = "do_checks_" + id;
//     if (!window[flagName]) return;

//     window[flagName] = false;

//     $.ajax({
//       url: statusUrlFor(template, id),
//       dataType: "script"
//     });
//   }

//   function setupAccountabilityPolling() {
//     var $root = $("#aa-accountability-reports");
//     if ($root.length === 0) return;

//     var template = $root.data("status-url-template");
//     if (!template) return;

//     // bootstrap flags from DOM
//     $(".js-report-status").each(function() {
//       var $el = $(this);
//       var id = $el.data("report-id");
//       var inProgress = String($el.data("in-progress")) === "true";
//       window["do_checks_" + id] = inProgress;
//     });

//     // bind once
//     $(document).off("click.accountability", ".js-report-regenerate").on("click.accountability", ".js-report-regenerate", function() {
//         var $link = $(this);
//         var id = $link.data("report-id");
//         console.log("regenerate clicked", id);

//         // immediate UI feedback (rails-ujs will still handle the remote POST)
//         $link.hide();
//         $("#regenerate_indicator_" + id + " img.loading").css("display", "inline");

//         $("#status_indicator_" + id).show();
//         $("#status_" + id).html("Regenerating...");
//         window["do_checks_" + id] = true;
//       });

//     // poll every 5 seconds
//     setInterval(function() {
//       $(".js-report-status").each(function() {
//         pollOne(template, $(this).data("report-id"));
//       });
//     }, 5000);
//   }

//   $(document).ready(setupAccountabilityPolling);
// })(jQuery);
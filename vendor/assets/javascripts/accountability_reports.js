$(document).ready(function () {
  var $dept = $("#department_search");
  if (!$dept.length) return;

  function renderOption(item) {
    if (!item.id) return item.text; // placeholder
    var sub = item.subtext ? "<div class='smaller'>" + item.subtext + "</div>" : "";
    return "<div>" + item.text + sub + "</div>";
  }

  function renderSelection(item) {
    // Keep selection compact and stable (usually just the main text)
    return item.text || "";
  }

  $dept.select2({
    width: "100%",
    placeholder: "Search department...",
    allowClear: true,
    minimumInputLength: 2,

    ajax: {
      url: $dept.data("autocomplete-url"),
      dataType: "json",
      delay: 200,
      data: function (params) { return { q: params.term }; },
      processResults: function (data) { return { results: data }; }
    },

    templateResult: function (item) { return $(renderOption(item)); }, // dropdown
    templateSelection: function (item) { return renderSelection(item); }, // selected value

    // allow HTML in dropdown + noResults link
    escapeMarkup: function (markup) { return markup; },

    language: {
      noResults: function () {
        var term =
          ($dept.data("select2") &&
            $dept.data("select2").dropdown &&
            $dept.data("select2").dropdown.$search)
            ? $dept.data("select2").dropdown.$search.val()
            : "";

        var url = "/expo/admin/department_extras/new";
        // optional prefill:
        // url += "?fixed_name=" + encodeURIComponent(term);

        return "No results. " +
          "<a href='" + url + "' target='_blank' rel='noopener noreferrer'>Create extra department</a>";
      }
    }
  });

  $dept.on("select2:select", function (e) {
    $("#authorizable_key").val(e.params.data.id);
  });

  $dept.on("select2:clear", function () {
    $("#authorizable_key").val("");
  });
});
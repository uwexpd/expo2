$(document).on('turbolinks:load', function () {

  // ── Config: maps each Select2 element to its Ransack checkbox IDs ──────────
  var selectGroups = [
    {
      selectId: 'academic_standing_select',
      fields: ['freshman', 'sophomore', 'junior', 'senior', 'fifth_year', 'graduate']
    },
    {
      selectId: 'citizenship_select',
      fields: ['us_citizen', 'permanent_resident', 'other_visa_status', 'hb_1079']
    }
  ];

  // Only run if this page's filter form is present
  if ($('#scholarship-filter-form').length === 0) return;

  // ── Deadline Month: native Ransack _in select — just apply Select2 ─────────
  // State restore is automatic since Ransack renders the selected values
  // directly into the <option selected> attributes.
  var $monthEl = $('#deadline_month_select');
  if ($monthEl.length) {
    if ($monthEl.hasClass('select2-hidden-accessible')) {
      $monthEl.select2('destroy');
    }
    $monthEl.select2({
      placeholder: 'Any',
      allowClear: true,
      dropdownParent: $('#scholarship-filters')
    });
  }

  // ── Initialize Select2 and restore state from Ransack params ───────────────
  selectGroups.forEach(function (group) {
    var $el = $('#' + group.selectId);

    // Destroy first if already initialized (safety net)
    if ($el.hasClass('select2-hidden-accessible')) {
      $el.select2('destroy');
    }

    $el.select2({
      placeholder: 'Any',
      allowClear: true,
      dropdownParent: $('#scholarship-filters')
    });

    // Pre-select options whose corresponding Ransack checkbox is checked
    var preSelected = group.fields.filter(function (field) {
      return $('#cb_' + field).is(':checked');
    });

    if (preSelected.length) {
      $el.val(preSelected).trigger('change');
    }
  });

  // ── On submit: write Select2 selections into the hidden Ransack inputs ──────
  $('#scholarship-filter-form').on('submit', function () {
    selectGroups.forEach(function (group) {
      var selected = $('#' + group.selectId).val() || [];

      group.fields.forEach(function (field) {
        var $cb = $('#cb_' + field);
        $cb.prop('checked', selected.indexOf(field) !== -1);
      });
    });
  });

});

// ── Destroy Select2 before Turbolinks caches the page ──────────────────────
// This prevents duplicate/empty dropdowns when navigating back
$(document).on('turbolinks:before-cache', function () {
  var selectIds = ['academic_standing_select', 'citizenship_select', 'deadline_month_select'];

  selectIds.forEach(function (id) {
    var $el = $('#' + id);
    if ($el.length && $el.hasClass('select2-hidden-accessible')) {
      $el.select2('destroy');
    }
  });
});

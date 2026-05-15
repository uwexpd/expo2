(function($) {
  function log() {
    if (window.console && console.log) console.log.apply(console, arguments);
  }

  function setStaffPrompt($staff, text) {
    $staff.empty();
    $staff.append($('<option>', { value: '', text: text || 'Select a unit first' }));

    // Refresh Select2 if it’s active
    if ($staff.hasClass('select2-hidden-accessible')) {
      $staff.val('').trigger('change.select2');
    } else {
      $staff.val('').trigger('change');
    }
  }

  function refreshStaff($unit, $staff, keepSelected) {
    var source = $staff.data('source') || $staff.attr('data-source');
    if (!source) {
      log('[appointment] missing data-source on staff select');
      return;
    }

    var unitId = $unit.val() || '';

    // If unit is blank, show prompt and do NOT call the server
    if (!unitId) {
      var prompt = $staff.data('prompt') || $staff.attr('data-prompt') || 'Select a unit first';
      setStaffPrompt($staff, prompt);
      return;
    }

    var selected = keepSelected
      ? ($staff.data('selected') || $staff.attr('data-selected') || $staff.val())
      : null;

    log('[appointment] GET', source, 'unit_id=', unitId);

    $.ajax({
      url: source,
      method: 'GET',
      dataType: 'json',
      data: { unit_id: unitId }
    })
      .done(function(items) {
        $staff.empty();

        // Optional: add a “Select staff” placeholder
        $staff.append($('<option>', { value: '', text: 'Select a staff person' }));

        $.each(items, function(_, item) {
          $staff.append($('<option>', { value: item.id, text: item.text }));
        });

        if (selected) $staff.val(String(selected));

        if ($staff.hasClass('select2-hidden-accessible')) {
          $staff.trigger('change.select2');
        } else {
          $staff.trigger('change');
        }
      })
      .fail(function(xhr) {
        log('[appointment] AJAX failed', xhr.status, xhr.responseText);
        setStaffPrompt($staff, 'Unable to load staff');
      });
  }

  $(document).ready(function() {
    var $unit = $('#appointment_unit_id');
    var $staff = $('#appointment_staff_person_id');

    if ($unit.length === 0 || $staff.length === 0) {
      log('[appointment] missing selects', { unitFound: $unit.length, staffFound: $staff.length });
      return;
    }

    // Initial population (new + edit)
    refreshStaff($unit, $staff, true);

    // Repopulate when unit changes
    $unit.on('change', function() {
      $staff.removeAttr('data-selected');
      $staff.data('selected', null);
      refreshStaff($unit, $staff, false);
    });
  });
})(window.jQuery);
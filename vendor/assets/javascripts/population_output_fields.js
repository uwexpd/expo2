// Helper: Safely build a jQuery class selector from element's classes
function getSafeClassSelector($el) {
  var classAttr = $el.attr('class');
  if (!classAttr) return null;
  var classes = classAttr.split(/\s+/).filter(function(c) { return c.length > 0; }).map(function(c) { return $.escapeSelector(c); }).join('.');
  return classes ? '.' + classes : null;
}

// Initialize SortableJS on the selected_population_field_codes list
function restorePopulationFieldCodesSortable() {
  var el = document.getElementById('selected_population_field_codes');
  if (!el) return;

  if (el._sortable) {
    el._sortable.destroy();
  }

  el._sortable = Sortable.create(el, {
    handle: '.sort-handle',
    animation: 150,
    onEnd: function (evt) {
      saveOutputFields('output_fields');
      commitOutputFields();
    }
  });
}

// Helper to decode HTML entities in a string: creates a temporary <textarea>, sets its innerHTML to the input string, and reads back the decoded value.
function decodeHtmlEntities(str) {
  var txt = document.createElement('textarea');
  txt.innerHTML = str;
  return txt.value;
}

// Toggle selection of an output field, add or remove from selected list, then save and commit changes
function toggleOutputField(containerID, fieldName, element) {
  var $element = $(element);
  var $parent = $element.parent();

  if ($parent.hasClass('custom_output_field')) {
    $parent.remove();
    restorePopulationFieldCodesSortable();

    $('#new_output_field_title').val($element.find('.association').first().html());
    var oldValue = $element.find('.fieldName').first().html();
    oldValue = decodeHtmlEntities(oldValue);
    
    var matches = oldValue.match(/^CUSTOM_OUTPUT_FIELD\((.+)\):(.+)/);
    if (matches) {
      $('#new_output_field').val(matches[2]);
    }
  } else {
    var klass = getSafeClassSelector($parent);
    if (klass && $('#selected_population_field_codes').find(klass).length > 0) {
      $element.removeClass('selected');
      removeOutputField($parent);

      var $allPopFields = $('#all_population_field_codes').find(klass);
      if ($allPopFields.length > 0) {
        $allPopFields.first().find('a').removeClass('selected');
      }
    } else {
      $element.addClass('selected');
      addOutputField($parent.clone(true));
    }
  }

  saveOutputFields(containerID);
  commitOutputFields();
}

// Add an output field element to the selected list and reinitialize sortable
function addOutputField($element) {
  $('#selected_population_field_codes').append($element);
  restorePopulationFieldCodesSortable();
}

// Remove an output field element from the selected list and toggle selected class on the corresponding element
function removeOutputField($element) {
  var klass = getSafeClassSelector($element);
  if (!klass) return;

  $('#selected_population_field_codes').find(klass).remove();

  var $allPopFields = $('#all_population_field_codes').find(klass);
  if ($allPopFields.length > 0) {
    $allPopFields.first().find('a').toggleClass('selected');
  }
  restorePopulationFieldCodesSortable();
}

// Save the current selected output fields as a JSON string into the hidden textarea/input
function saveOutputFields(containerID) {
  var fieldNames = $('#selected_population_field_codes .selected .fieldName').map(function() {
    return $(this).html();
  }).get();

  $('#' + containerID).val(JSON.stringify(fieldNames));
  $('#save_output_fields_status').html('Saving...');
}

// Send AJAX PUT request to save output fields to server
function commitOutputFields() {
  $.ajax({
    url: commitOutputFieldsURL,
    method: 'PUT',
    data: { output_fields: $('#output_fields').val() },
    dataType: 'script',
    success: function() {
      // Success feedback handled by server JS response or here if needed
    },
    error: function() {
      $('#save_output_fields_status').html('<span class="mi red_color" >error</span> Save Failed');
    }
  });
}

// Add a custom output field from input values and save changes
function addCustomOutputField() {
  var val = $('#new_output_field').val();
  var titleVal = $('#new_output_field_title').val();

  // Sanitize class name by replacing problematic characters with underscores
  var safeClassName = val.replace(/[\?, \(\)\-\=\:\#\|\;\"\'\.\<\>\[\]\{\}]/g, '_');

  var $li = $('<li></li>').addClass(safeClassName).addClass('selected').addClass('custom_output_field');

  var html = '<span class="sort-handle mi">swap_vert</span>' +
    '<a class="placeholder_text_link selected" href="#" onclick="toggleOutputField(\'output_fields\', \'code_text\', this); return false;">' +
    '<span class="custom outline tag" style="margin-left:0">Custom</span>' +
    '<span class="association">' + titleVal + '</span>' + "<i class='mi'>arrow_right</i>" +
    val +
    '<span class="fieldName" style="display:none">CUSTOM_OUTPUT_FIELD(' + titleVal + '):' + val + '</span>' +
    '</a>';

  $li.html(html);

  addOutputField($li);
  saveOutputFields('output_fields');
  commitOutputFields();

  $('#new_output_field').val('');
  $('#new_output_field_title').val('');
}
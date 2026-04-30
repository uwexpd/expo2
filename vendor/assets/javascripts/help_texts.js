(function() {
  function toggleHelpTextFields() {
    var $select = $('#help_text_type_select');
    if ($select.length === 0) return;

    var isModel = ($select.val() === 'ModelHelpText');
    $('#help_text_model_fields').toggle(isModel);
    $('#help_text_key_fields').toggle(!isModel);
  }

  function bindHelpTextForm() {
    var $select = $('#help_text_type_select');
    if ($select.length === 0) return;

    toggleHelpTextFields();
    $select.off('change.helptext').on('change.helptext', function() {
      toggleHelpTextFields();
      // if switching to ModelHelpText, populate attributes immediately
      updateAttributesForModel($('#help_text_attribute_name').val());
    });
  }

  function updateAttributesForModel(selectedValue) {
    var $model = $('#help_text_object_type');
    var $attr  = $('#help_text_attribute_name');
    if ($model.length === 0 || $attr.length === 0) return;

    var modelName = $model.val();    

    $attr.empty().append($('<option>', { value: '', text: 'Select an attribute' }));
    if (!modelName) return;

    console.log("model changed to:", modelName);

    $.getJSON('/expo/admin/help_texts/model_attributes', { model: modelName }).done(function(attrs) {
        $.each(attrs, function(_, a) {
          $attr.append($('<option>', { value: a, text: a }));
        });
    });    
  }

  function bindModelAttributePicker() {
  $(document).off('change.helptextattrs', '#help_text_object_type').on('change.helptextattrs', '#help_text_object_type', function() {
      updateAttributesForModel(null);
      });

    // optional: initial populate if a model is already selected
    updateAttributesForModel($('#help_text_attribute_name').val());
  }

  function initHelpTextAdmin() {
    bindHelpTextForm();
    bindModelAttributePicker();
  }

  $(document).on('turbolinks:load', initHelpTextAdmin);
  $(document).ready(initHelpTextAdmin);
})();
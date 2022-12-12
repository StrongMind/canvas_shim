function flipIcon(element, threshDisabled) {
  var icon = element.children("i");
  if (threshDisabled) {
    icon.removeClass("icon-edit");
    icon.addClass("icon-trash");
  } else {
    icon.removeClass("icon-trash");
    icon.addClass("icon-edit");
  }
}

$(window).on("load", function(event) {
  $('#edit_passing_thresholds_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    let thresholdFields = getThresholdFields();
    let thresholdFieldsDisabled = thresholdFields[0].disabled;

    editThresholdFields(thresholdFields, thresholdFieldsDisabled)

    flipIcon($(this), thresholdFieldsDisabled);
  });

  function getThresholdFields() {
    return Array.from($('.passing-threshold-number-field'));
  }

  function editThresholdFields(thresholdFields, thresholdFieldsDisabled){
    thresholdFields.forEach(function(el, i) {
      var initialFieldValue = $(el).val();
      var id_string = $(el).attr('id').split('_').slice(2).join('_');
      var edited_id_string = id_string + "_edited";
      
      $(el).attr('disabled', !thresholdFieldsDisabled);
      $("#" + edited_id_string).val(thresholdFieldsDisabled);
      
      if($("#" + id_string).prop('disabled')) {
        $("#" + id_string).val(initialFieldValue);
      }
    });
  }
});

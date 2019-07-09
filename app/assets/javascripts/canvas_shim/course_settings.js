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
  var initialVal = $('#passing_threshold').val();
  $('#edit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var passThreshDisabled = $('#passing_threshold').prop('disabled');
    $('#passing_threshold').prop('disabled', !passThreshDisabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshDisabled + " />")
    if ($('#passing_threshold').prop('disabled')) {
      $('#passing_threshold').val(initialVal);
    }

    flipIcon($(this), passThreshDisabled);
  });

  var initialUnitVal = $('#passing_unit_threshold').val();
  $('#edit_unit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var unitPassThreshDisabled = $('#passing_unit_threshold').prop('disabled');
    $('#passing_unit_threshold').prop('disabled', !unitPassThreshDisabled);
    $("#unit_threshold_edited").remove();
    $(this).append("<input type='hidden' id='unit_threshold_edited' name='unit_threshold_edited' value=" + unitPassThreshDisabled + " />")
    if ($('#passing_unit_threshold').prop('disabled')) {
      $('#passing_unit_threshold').val(initialUnitVal);
    }

    flipIcon($(this), unitPassThreshDisabled);
  });
});

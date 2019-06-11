$(window).on("load", function(event) {
  $('#edit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var initialVal = $('#passing_threshold').val();
    var passThreshDisabled = $('#passing_threshold').prop('disabled');
    $('#passing_threshold').prop('disabled', !passThreshDisabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshDisabled + " />")
    if (passThreshDisabled) {
      $('#passing_threshold').val(initialVal);
    }
  });
});

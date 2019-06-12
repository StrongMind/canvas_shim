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
  });
});

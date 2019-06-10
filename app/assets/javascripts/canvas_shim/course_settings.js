$(window).on("load", function(event) {
  $('#edit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var passThreshEnabled = $('#passing_threshold').prop('disabled');
    $('#passing_threshold').prop('disabled', !passThreshEnabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshEnabled + " />")
  });
});

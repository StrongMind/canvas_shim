$(window).on("load", function(event) {
  $('#edit_school_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var passThreshEnabled = $('#account_settings_score_threshold').prop('disabled');
    $('#account_settings_score_threshold').prop('disabled', !passThreshEnabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshEnabled + " />")
  });
});

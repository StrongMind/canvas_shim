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
  var initialVal = $('#account_settings_score_threshold').val();
  $('#edit_school_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var passThreshDisabled = $('#account_settings_score_threshold').prop('disabled');
    $('#account_settings_score_threshold').prop('disabled', !passThreshDisabled);
    $("#threshold_edited").remove();
    $(this).append("<input type='hidden' id='threshold_edited' name='threshold_edited' value=" + passThreshDisabled + " />")
    if ($('#account_settings_score_threshold').prop('disabled')) {
      $('#account_settings_score_threshold').val(initialVal);
    }

    flipIcon($(this), passThreshDisabled);
  });

  var initialUnitVal = $('#account_settings_unit_score_threshold').val();
  $('#edit_school_unit_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var unitPassThreshDisabled = $('#account_settings_unit_score_threshold').prop('disabled');
    $('#account_settings_unit_score_threshold').prop('disabled', !unitPassThreshDisabled);
    $("#unit_threshold_edited").remove();
    $(this).append("<input type='hidden' id='unit_threshold_edited' name='unit_threshold_edited' value=" + unitPassThreshDisabled + " />")
    if ($('#account_settings_unit_score_threshold').prop('disabled')) {
      $('#account_settings_unit_score_threshold').val(initialUnitVal);
    }

    flipIcon($(this), unitPassThreshDisabled);
  });

  var initialDiscussionVal = $('#account_settings_discussion_score_threshold').val();
  $('#edit_school_discussion_threshold_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var discussionPassThreshDisabled = $('#account_settings_discussion_score_threshold').prop('disabled');
    $('#account_settings_discussion_score_threshold').prop('disabled', !discussionPassThreshDisabled);
    $("#discussion_threshold_edited").remove();
    $(this).append("<input type='hidden' id='discussion_threshold_edited' name='discussion_threshold_edited' value=" + discussionPassThreshDisabled + " />")
    if ($('#account_settings_discussion_score_threshold').prop('disabled')) {
      $('#account_settings_discussion_score_threshold').val(initialDiscussionVal);
    }

    flipIcon($(this), discussionPassThreshDisabled);
  });
});

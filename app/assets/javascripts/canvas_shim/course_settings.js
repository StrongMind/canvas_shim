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

function confirmDistribute() {
  return confirm(
    "You are about to distribute due dates between " + ENV.start_date +
    " and " + ENV.end_date + ". If you have different dates selected, " +
    "click the 'Update Course Details' button at the bottom of this page to save those dates. " +
    "Please confirm that you want to distribute between " + ENV.start_date + " and " + ENV.end_date + "."
  )
}

function confirmClear() {
  return confirm(
    "You are about to clear all due dates from this course. " +
    "Course assignments will no longer have due dates or calendar events. " +
    "Please confirm that you want to complete this action."
  )
}

$(window).on("load", function(event) {
  $('#edit_passing_thresholds_btn').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    let thresholdFields = getThresholdFields();
    let thresholdFieldsDisabled = thresholdFields[0].disabled;

    editThresholdFields(thresholdFields, thresholdFieldsDisabled);

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


  $(".endpoint-btn").click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var id = $(this).attr("id");
    if (id === "distribute_due_dates" && !(ENV.start_date && ENV.end_date)) {
      return $.flashError(
        "Please save a start and end date to this course before distributing due dates."
      )
    } else if (id === "distribute_due_dates" && !confirmDistribute() || id === "clear_due_dates" && !confirmClear()) {
      return;
    }

    var target = $(this).data("target");
    var id = $(this).attr("id");

    $.ajax({
      url: target,
      type: 'POST',
      success: function() {
        $(".endpoint-btn").prop("disabled", "true");
        $("#distributing-msg").removeClass("hidden");

        if (id === "clear_due_dates") {
          return $.flashMessage(
            "Your due dates are currently being cleared. They should be removed from the modules page in a few minutes."
          )
        }

        return $.flashMessage(
          "Your due dates are currently being distributed. They should be visible on the modules page in a few minutes."
        )
      },
      error: function() {
        return $.flashError(
          "Something went wrong!  Please wait a moment and try again. If the problem persists, contact an administrator."
        )
      }
    });
  });
});

$(window).on("load", function(event) {
  function replacer(value) {
    if (value) { return value.replace("at", "") }
  }

  function validCourseDates() {
    var start_at = replacer($("#course_start_at").val());
    var end_at = replacer($("#course_conclude_at").val());
    return Date.parse(start_at) && Date.parse(end_at);
  }

  if (ENV['auto_due_dates']) {
    $("#dateAdjustCheckbox").remove();
    $("label[for=dateAdjustCheckbox]").remove();
  }

  if (!validCourseDates()) {
    $("#copy-course-btn").prop("disabled", true);
  }

  $(document).on("change", "#course_start_at, #course_conclude_at", function(e) {
    $("#copy-course-btn").prop("disabled", true);
    if (validCourseDates()) {
      $("#copy-course-btn").prop("disabled", false);
    }
  });

  $("#copy-btn-wrapper").on("click", function(event) {
    if ($("#copy-course-btn[disabled]").length) {
      alert("Please add start and end dates before importing this course.");
    }
  });
});
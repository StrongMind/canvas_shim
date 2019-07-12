$(window).on("load", function(event) {
  function validCourseDates() {
    var start_at = $("#course_start_at").val().replace("at", "");
    var end_at = $("#course_conclude_at").val().replace("at", "");
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
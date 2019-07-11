$(window).on("load", function(event) {
  if (ENV['auto_due_dates']) {
    $("#dateAdjustCheckbox").remove();
    $("label[for=dateAdjustCheckbox]").remove();
  }

  if (!(ENV["OLD_START_DATE"] && ENV["OLD_END_DATE"])) {
    $("#copy-course-btn").prop("disabled", true);
  }

  $(document).on("change", "#course_start_at, #course_conclude_at", function(e) {
    $("#copy-course-btn").prop("disabled", true);
    var start_at = $("#course_start_at").val();
    var end_at = $("#course_conclude_at").val();
    if (Date.parse(start_at) && Date.parse(end_at)) {
      $("#copy-course-btn").prop("disabled", false);
    }
  });

  $("#copy-btn-wrapper").on("click", function(event) {
    if ($("#copy-course-btn[disabled]").length) {
      alert("Please add start and end dates before importing this course.");
    }
  });
});
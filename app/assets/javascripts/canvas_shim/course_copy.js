$(window).on("load", function(event) {
  $("#copy-course-btn").prop("disabled", true);

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
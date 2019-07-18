$(window).on("load", function(event) {
  $("#caag-course-select").change(function(e) {
    var oldURL = window.location.pathname;
    var newURL = $(this).children(":selected").data("url");

    if (oldURL !== newURL) {
      var finalURL = window.location.href.replace(oldURL, newURL)
      window.location.replace(finalURL);
    }
  });

  $('#studentDetails').DataTable();
});

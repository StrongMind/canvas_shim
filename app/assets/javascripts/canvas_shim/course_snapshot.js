$(window).on("load", function(event) {
  $('.icon-x').click(function(e) {
    $(this).parents('tr').remove();
    table.rows().draw(false)
  });

  $("#course-snapshot-course-select").change(function(e) {
    var oldURL = window.location.pathname;
    var newURL = $(this).children(":selected").data("url");

    if (oldURL !== newURL) {
      var finalURL = window.location.href.replace(oldURL, newURL)
      window.location.replace(finalURL);
    }
  });

  $('#studentDetails').DataTable();

  // toggle popover on the activity chart
  $('#activity-chart-info, .popover-close').click(function() {
    $('.course-snapshot-activity-chart-popover').toggleClass('popover-visible');
  })
});

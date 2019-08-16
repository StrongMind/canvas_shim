$(window).on("load", function(event) {

  ga('create', ENV['analytics']['ga_tracking_id']);
  
  $("#course-snapshot-course-select").change(function(e) {
    var oldURL = window.location.pathname;
    var newURL = $(this).children(":selected").data("url");

    if (oldURL !== newURL) {
      ga('send', 'event', 
        'Snapshot: Course Selection', 
        'click', 
        $(this).children(":selected").text()
      );
      var finalURL = window.location.href.replace(oldURL, newURL)
      window.location.replace(finalURL);
    }
  });

  $('#studentDetails').DataTable();

  // toggle popover on the activity chart
  $('#activity-chart-info, .popover-close').click(function() {
    $('.course-snapshot-activity-chart-popover').toggleClass('popover-visible');
  })

  // Capture card link clicks
  $('body').on('click', '.card-link', function() {
    ga('send', 'event', 
        'Snapshot: Card Link', 
        'click', 
        $(this).text(),
    );
  });

  // capture table sorts
  $('#studentDetails').on('click', 'thead th', function() {
    ga('send', 'event', 
      'Snapshot: Student Detail Table', 
      $(this).attr('class'), 
      $(this).text(),
    );
  });

  // capture search event
  var typingTimer;
  var doneTypingInterval = 500;

  $('#studentDetails_filter').on('change', 'label input', function() {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(triggerSearchEvent, doneTypingInterval);
  });

  // capture access report info click
  $('#activity-chart-info').on('click', '.icon-info', function() {
    ga('send', 'event', 
      'Snapshot: Access Report', 
      'click', 
      'Access Report Info Icon'
    );
  });
});

function triggerSearchEvent() {
  ga('send', 'event', 
      'Snapshot: Student Detail Table', 
      'search'
    );
}

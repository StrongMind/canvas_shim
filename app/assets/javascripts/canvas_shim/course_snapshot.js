$(window).on("load", function(event) {
  $("#course-snapshot-course-select").change(function(e) {
    var oldURL = window.location.pathname;
    var newURL = $(this).children(":selected").data("url");

    if (oldURL !== newURL) {
      ga('send', 'event', 
        'Snapshot', 
        'clicked', 
        'Course Selection',
        {'oldUrl': oldURL, 'newUrl': newURL}
      );
      var finalURL = window.location.href.replace(oldURL, newURL)
      window.location.replace(finalURL);
    }
  });

  var table = $('#studentDetails').DataTable();

  // toggle popover on the activity chart
  $('#activity-chart-info, .popover-close').click(function() {
    $('.course-snapshot-activity-chart-popover').toggleClass('popover-visible');
  })

  // Capture card link clicks
  $('body').on('click', '.card-link', function() {
    ga('send', 'event', 
        'Snapshot', 
        'clicked', 
        'Card Link',
        {linkText: $(this).text(), linkUrl: $(this).href}
    );
  });

  // capture table sorts
  $('#studentDetails').on('click', 'thead th', function() {
    ga('send', 'event', 
      'Snapshot', 
      'clicked', 
      'Student Detail Table Sort',
      {column: $(this).text(), order: $(this).attr('class')}
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
      'Snapshot', 
      'clicked', 
      'Access Report Info'
    );
  });
});

function triggerSearchEvent() {
  ga('send', 'event', 
      'Snapshot', 
      'search', 
      'Student Detail Table Search'
    );
}

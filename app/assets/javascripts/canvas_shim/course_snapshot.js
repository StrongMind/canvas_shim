$(window).on("load", function(event) {

  if (typeof ga === 'function') {
    ga('create', ENV["analytics"]["ga_tracking_id"]);
  }
  
  $("#course-snapshot-course-select").change(function(e) {
    var oldURL = window.location.pathname;
    var newURL = $(this).children(":selected").data("url");

    if ((typeof ga === 'function') && oldURL !== newURL) {
      ga('send', 'event', 
        'Snapshot: Course Selection', 
        'click', 
        $(this).children(":selected").text()
      );
      var finalURL = window.location.href.replace(oldURL, newURL)
      window.location.replace(finalURL);
    }
  });

  // toggle popover on the activity chart
  $('#activity-chart-info, .popover-close').click(function() {
    $('.course-snapshot-activity-chart-popover').toggleClass('popover-visible');
  })

  if(typeof ga === 'function') {
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
  }

  if ($('.course-snapshot-detail-row').length) {
    $('#studentDetails').hide();
    $("#placeHolderStudentDetails").DataTable();
    $('.course-snapshot-detail-row').each(function(student) {
      fillDetailRow($(this));
    });
  }
});

function triggerSearchEvent() {
  ga('send', 'event', 
      'Snapshot: Student Detail Table', 
      'search'
    );
}

function fillDetailRow(student) {
  var courseID = student.data('course-id');
  var enrID = student.data('enr-id');
  if (!enrID || !courseID) { return }

  var ajaxResponse = $.getJSON('/api/v1/courses/' + courseID + '/enrollments/' + enrID + '/snapshot');
  ajaxResponse.done(function(response) {
    student.children('.enr-last-active').text(response.last_active);
    student.children('.enr-last-submission').text(response.last_submission);
    student.children('.enr-missing-assignments').text(response.missing_assignments);
    student.children('.enr-current-score').text(response.current_score);
    student.children('.enr-requirements-completed').text(response.requirements_completed);
    student.children('.enr-alerts-count').text(response.alerts);

    student.find('.enr-progress-bar .value span').text(response.course_progress);
    student.find('.enr-progress-bar .value').css('width', response.course_progress);
    student.find('.enr-progress-bar .progress').attr('data-label', response.course_progress);

    if (doneLoading()) {
      $('#studentDetails').DataTable();
      $("#placeHolderStudentDetails").remove();
      $('#placeHolderStudentDetails_wrapper').remove();
      $('#studentDetails').show();
    }
  }).fail(function() {
    $('#loading-cell').text("Request failed. Please try again.");
  });
}

function doneLoading() {
  return !$('.course-snapshot-detail-row td').get().some(function(element) {
    return $(element).text().trim() === "Waiting...";
  });
}

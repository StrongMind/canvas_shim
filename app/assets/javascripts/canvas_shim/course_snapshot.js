$(window).on("load", function(event) {

  $('#course-progress-average-card .card-text').hide()


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
  } else {
    replaceDataTable();
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
    student.children('.course-progress-data').text(parseFloat(response.course_progress));

    student.find('.enr-progress-bar .value').css('width', response.course_progress);
    student.find('.enr-progress-bar .progress').attr('data-label', response.course_progress);


    if (doneLoading()) { replaceDataTable(); updateAverageCourseProgress() }

  }).fail(function() {
    $('#loading-cell').text("Request failed. Please try again.");
  });
}

function doneLoading() {
  return !$('.course-snapshot-detail-row td').get().some(function(element) {
    return $(element).text().trim() === "Waiting...";
  });
}

function replaceDataTable() {
  $('#studentDetails').DataTable(
    {
      "columnDefs": [
        {
          "targets": [7],
          "orderable": false,
          "visible": false,
        },
        {
          "targets": [0], // Target the first column
          "type": "string", // Set alphabetical sorting for the first column
          "orderable": true, // Allow sorting for the first column
          "visible": true // Make the first column visible
        },
        {
          "targets": "_all", // Target all columns
          "type": "num-html-na", // Set numerical sorting for all columns
          "orderable": true, // Allow sorting for all columns
          "visible": true // Make all columns visible
        }
      ]
    }
  );
  $("#placeHolderStudentDetails").remove();
  $('#placeHolderStudentDetails_wrapper').remove();
  $('#studentDetails').show();
}

// this allows dataTable to sort numerics and strings in the same column
$(document).ready(function() {
  // Define a custom sorting function
  jQuery.extend(jQuery.fn.dataTableExt.oSort, {
    "num-html-na-pre": function(data) {

      // For the progress bar column, it is sorting it as a string, we only want the progress value
      var temp = document.createElement('div');
      temp.innerHTML = data;
      var htmlObject = temp.querySelector('.progress');
      if (htmlObject) {
        return parseFloat(htmlObject.getAttribute('data-label'));
      }

      return data === "N/A" ? -Infinity : parseFloat(data);
    },
    "num-html-na-asc": function(a, b) {
      return a - b;
    },
    "num-html-na-desc": function(a, b) {
      return b - a;
    }
  });
});

function updateAverageCourseProgress() {

  jQuery.fn.dataTable.Api.register( 'course_progress_average()', function () {
    var data = this.flatten();
    var sum = data.reduce( function ( a, b ) {
        return (a*1) + (b*1); // cast values in-case they are strings
    }, 0 );

    return sum / data.length;
  } );


  var table = $('#studentDetails').DataTable()
  var average = table.column( 7 ).data().course_progress_average()
  $('#course-progress-average-card .dot-loader').toggle()
  $('#course-progress-average').append(average.toFixed(1))
  $('#course-progress-average-card .card-text').toggle()

}

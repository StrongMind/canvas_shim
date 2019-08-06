  var alertsTable;
  var xIcon;

  function toggleHidden(arr) {
    arr.forEach(function(element) {
      element.toggleClass("hidden");
    });
  }

  $(function(){
    alertsTable = $('#alertsTable').DataTable(
      {
        "columnDefs": [
          {
            "targets": [4],
            "orderable": false,
            "searchable": false,
          },
          {
            targets: [ 0, 1, 2, 3 ],
            className: 'mdl-data-alertsTable__cell--non-numeric'
          }
        ]
      }
    );

    $('#alertsTable .icon-x').click(function(e) {
      xIcon = $(this);

      $.ajax({
        url: xIcon.data('url'),
        type: 'DELETE',
        data: { alert_id: xIcon.data('alert') },
        success: function() {
          alertsTable.row(xIcon.parents('tr')).remove().draw();
        }
      });
    });

    $('#bulk-delete-btn').click(function(e) {
       toggleHidden(
         [$(".icon-x"), $(".bulk-delete-checks"), $('#bulk-delete-confirm')]
       );

       if ($(this).text() === "Go Back") {
         $(this).text("Delete Multiple");
       } else {
         $(this).text("Go Back");
       }
    });

    $('#bulk-delete-confirm').click(function(e) {
       var submits = [];
       var removableRows = [];
       var self = this;
       $(".bulk-delete-checks:checked").each(function(i) {
         submits.push($(this).val());
         removableRows.push($(this).parents('tr'));
       });

       $.ajax({
        url: $(self).data('url'),
        type: 'POST',
        headers: {
          contentType: "application/json"
        },
        data: { alert_ids: JSON.stringify(submits) },
        success: function() {
          removableRows.forEach(function(row) {
            alertsTable.row(row).remove().draw();
          });
        }
      });
    });
  });

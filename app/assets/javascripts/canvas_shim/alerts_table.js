  var alertsTable;
  var xIcon;

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
       $(".icon-x").toggleClass("hidden");
       $(".bulk-delete-checks").toggleClass("hidden");
    });
  });

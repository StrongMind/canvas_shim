  var alertsTable;
  var xIcon;

  function toggleHidden(arr, className) {
    arr.forEach(function(element) {
      element.toggleClass(className);
    });
  }

  $(function(){
    alertsTable = $('#alertsTable').DataTable(
      {
        "columnDefs": [
          {
            "targets": [5, 6],
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
         [$(".icon-x"), $(".bulk-delete-checks"), $('#bulk-delete-confirm')],
          "hidden"
       );
       toggleHidden([$('#delete-column-header')], "visibility-hidden");

       if ($(this).text() === "Go Back") {
         $(this).text("Delete Multiple Messages");
       } else {
         $(this).text("Go Back");
       }
    });

    $('#bulk-delete-confirm').click(function(e) {
       var submits = [];
       var removableRows = [];
       var self = this;
       var checkedAlerts = $(".bulk-delete-checks:checked");

       checkedAlerts.each(function(i) {
         submits.push($(this).val());
         removableRows.push($(this).parents('tr'));
       });

      if (checkedAlerts.length) {
        // show the loading icon and disable the buttons
        toggleHidden([$('.dot-loader')], "hidden");
        $('#bulk-delete-confirm, #bulk-delete-btn').attr("disabled", "disabled");

        $.ajax({
          url: $(self).data('url'),
          type: 'POST',
          headers: {
            contentType: "application/json"
          },
          data: { alert_ids: submits },
          success: function() {
            // remove deleted rows
            removableRows.forEach(function(row) {
              alertsTable.row(row).remove().draw();
            });

            // revert table to single-delete state
            toggleHidden(
              [$(".icon-x"), $(".bulk-delete-checks"), $('#bulk-delete-confirm'), $('.dot-loader')],
              "hidden"
            );
            toggleHidden([$('#delete-column-header')], "visibility-hidden");
            $('#bulk-delete-confirm, #bulk-delete-btn').removeAttr("disabled");
            $('#bulk-delete-btn').text("Delete Multiple Messages")
          },
          error: function() {
            return $.flashError(
              "Something went wrong!  Please wait a moment and try again.  If the problem persists, contact an administrator."
            )
          }
        });
      } else {
        return $.flashError(
          "Please select at least one alert to delete."
        )
      }
    });

    $('#bulk-delete-select').click(function() {
      if(this.checked){
        $(this).siblings("label").text("Deselect All");
        $(':checkbox').each(function() {
          this.checked = true;
        });
      } else {
        $(this).siblings("label").text("Select All");
        $(':checkbox').each(function() {
          this.checked = false;
        });
      }
    });
  });

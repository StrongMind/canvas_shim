$(window).on("load", function(event) {
  if (ENV['AUTO_DUE_DATES']) {
    $('#submitMigration').on("click", function(event){
      var form = $("#migrationConverterContainer");
      event.preventDefault();
      if (!ENV["OLD_START_DATE"] || !ENV["OLD_END_DATE"]) {
        return $.flashError(
          "Course must have start and end dates before importing content"
        )
      } else {
        form.trigger("submit");
      }
    });
  }
});
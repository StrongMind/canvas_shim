$(window).on("load", function(event) {
  if ((ENV['excused_discussions'] || []).length) {
    var excusedInterval = setInterval(function() {
      ENV['excused_discussions'].forEach(function(topic) { 
        var discussion = $(topic).find('.title');
        discussion.text(discussion.text() + " (Excused)");
      });

      if ($(ENV['excused_discussions'][0]).length) {
        clearInterval(excusedInterval);
      }
    }, 1000);
  }
});
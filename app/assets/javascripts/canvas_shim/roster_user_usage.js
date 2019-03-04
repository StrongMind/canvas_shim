
$(window).on("load", function(event) {
  var cal = new CalHeatMap();
  cal.init({
    data: window.ENV.PAGE_VIEWS_BY_HOUR,
    domain : "day",       // Group data by days
    subDomain : "x_hour", // Split each day by hours
    range : 2,
    colLimit: 24,
    cellSize: 30,
    label: {
        position: "bottom",
        // width: 46,
        rotate: "left"
    },
    scale: [1, 3, 6, 9]
  });
})
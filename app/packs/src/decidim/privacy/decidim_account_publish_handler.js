$(() => {
  $("#privacy-consent").on("open.zf.reveal", function() {
    console.log("LOADED");
    const openerId = $("#privacy-consent").data("open");
    console.log("Opener ID: ", openerId);
  });
})

$(document).ready(function() {

  $(".publish-modal").on("click", function(el) {
    let redirectUrl = $(el.target).data("redirect-url");
    $("#publishAccountModal .update-privacy").attr("data-redirect-url", redirectUrl);
  });

  $(document).on("ajax:complete", ".update-privacy", function(event, response) {
    console.log(response)
  });
})

$(() => {
  let $publishAccountModal = $("#publishAccountModal");
  if ($publishAccountModal.length < 1) {
    $publishAccountModal = null;
  }

  let publishRedirect = localStorage.getItem("loginRedirect");
  if (publishRedirect && $publishAccountModal) {
    $publishAccountModal.foundation("open");
    localStorage.removeItem("loginRedirect");
  }
  // We capture the element which has a login modal attached with it to check after login if they have the publish condition after they
  // have logged in. These elements might or might not have the publish requirement, but if they will have the data-open of publishAccountModal, then they
  // we should open the modal.

  $("#loginModal").on("open.zf.reveal", () => {
    localStorage.setItem("loginRedirect", true);
  });

  $("#loginModal").on("closed.zf.reveal", () => {
    localStorage.removeItem("loginRedirect");
  });

  if ($publishAccountModal) {
    $publishAccountModal.on("open.zf.reveal", (ev) => {
      let redirectUrl = $(ev.target).attr("data-redirect-url");
      $(".update-privacy").closest("form").attr("data-redirect-url", redirectUrl);
    });

    $publishAccountModal.on("closed.zf.reveal", () => {
      $("[data-triggering-modal]:first").removeAttr("data-triggering-modal");
    });
  }

  document.querySelectorAll("[data-open='loginModal']").forEach((el) => {
    el.addEventListener("click", (ev) => {
      console.log("OPEN LOGIN");
      console.log(ev.target.id);
    })
  });

  // We need to know which element triggered the publish modal to open, to redirect
  // the user to the redirect-url
  $(document).on("click", ".publish-modal", (ev) => {
    $(ev.target).attr("data-triggering-modal", true)
  })

  // The ajax:complete or ajax:success does not get the response from the controller
  $(document).on("ajax:complete", $(".update-privacy").closest("form"), function() {
    let triggeringElement = $("[data-triggering-modal]:first");
    window.location.href = triggeringElement.data("redirect-url");
  });
})

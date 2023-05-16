$(() => {
  let $publishAccountModal = $("#publishAccountModal");
  if ($publishAccountModal.length < 1) {
    $publishAccountModal = null;
  }
  let triggeredLoginElement = localStorage.getItem("loginTriggeringElement")

  // We capture the element which has a login modal attached with it to check after login if they have the publish condition after they
  // have logged in. These elements might or might not have the publish requirement, but if they will have the data-open of publishAccountModal, then they
  // we should open the modal.

  if ($publishAccountModal) {
    if (triggeredLoginElement) {
      let element = document.getElementById(triggeredLoginElement)
      if (element) {
        $publishAccountModal.foundation("open")
        $publishAccountModal.find("form").attr("data-redirect-url", element.getAttribute("data-redirect-url"))
      }
      localStorage.removeItem("loginRedirect");
    }
    document.querySelectorAll("[data-open='publishAccountModal']").forEach((el) => {
      el.addEventListener("click", (ev) => {
        console.log($publishAccountModal.find("form"))
        $publishAccountModal.find("form").attr("data-redirect-url", ev.target.getAttribute("data-redirect-url"))
      })
    });

    $publishAccountModal.on("closed.zf.reveal", () => {
      $publishAccountModal.find("form").removeAttr("data-redirect-url")
    });
  }

  document.querySelectorAll("[data-open='loginModal']").forEach((el) => {
    el.addEventListener("click", (ev) => {
      localStorage.setItem("loginTriggeringElement", ev.target.id);
    })
  });

  $("#loginModal").on("closed.zf.reveal", () => {
    localStorage.removeItem("loginTriggeringElement");
  });

  // We need to know which element triggered the publish modal to open, to redirect
  // the user to the redirect-url
  $(document).on("click", ".publish-modal", (ev) => {
    $(ev.target).attr("data-triggering-modal", true)
  })

  // The ajax:complete or ajax:success does not get the response from the controller
  $(document).on("ajax:complete", $(".update-privacy").closest("form"), function(el) {
    window.location.href = el.target.getAttribute("data-redirect-url");
  });
})

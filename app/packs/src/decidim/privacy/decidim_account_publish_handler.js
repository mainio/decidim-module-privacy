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
        localStorage.removeItem("loginTriggeringElement");
      }
    }

    document.querySelectorAll("[data-open='publishAccountModal']").forEach((el) => {
      el.addEventListener("click", (ev) => {
        let redirectUrl = ev.target.getAttribute("data-redirect-url")
        if (redirectUrl) {
          $publishAccountModal.find("form").attr("data-redirect-url", ev.target.getAttribute("data-redirect-url"))
        } else {
          // Its a post request
          $publishAccountModal.find("form").attr("data-submit-form-button", ev.target.id)
        }
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

  // const removeAllPublishModals = () => {
  //   document.querySelectorAll("[data-open='publishAccountModal']").forEach((el) => {
  //     el.removeAttribute("data-open")
  //   })
  // }

  // const submitFormFor = (postRequest) => {
  //   console.log(document.getElementById(postRequest).closest("form"))
  //   document.getElementById(postRequest).closest("form").submit()
  // }

  $(document).on("ajax:complete", $(".update-privacy").closest("form"), (el) => {
    let redirectDestination =  el.target.getAttribute("data-redirect-url")
    if (redirectDestination) {
      window.location.href = el.target.getAttribute("data-redirect-url");
    } else {
      // This is a post request
      // removeAllPublishModals()
      // $publishAccountModal.foundation("close")
      // let submittedFormId = el.target.getAttribute("data-submit-form-button")
      // submitFormFor(submittedFormId)
    }
  });
});

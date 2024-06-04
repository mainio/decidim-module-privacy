$(() => {
  let $publishAccountModal = $("#publish-account-modal");
  if ($publishAccountModal.length < 1) {
    $publishAccountModal = null;
  }
  let triggeredLoginElement = localStorage.getItem("loginTriggeringElement")
  console.log(localStorage)
  // We capture the element which has a login modal attached with it to check after login if they have the publish condition after they
  // have logged in. These elements might or might not have the public account requirement to show the modal.
  const setFormValues =  (ev) => {
    if (!$publishAccountModal) {
      return
    }

    let redirectUrl = ev.target.getAttribute("data-redirect-url")
    let dataPrivacy = ev.target.getAttribute("data-privacy") || "{}"
    if (dataPrivacy && dataPrivacy !== "{}") {
      $publishAccountModal.find("form").attr("data-triggering-privacy", ev.target.id)
    } else {
      $publishAccountModal.find("form").attr("data-redirect-url", redirectUrl)
    }
  }

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
      el.addEventListener("click", setFormValues)
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

  const setCommentData = (buttonElement) => {
    buttonElement.setAttribute("data-popup-comment-id", buttonElement.closest("form").id)
  }

  const handleCommentAction = (ev) => {
    if ($publishAccountModal !== null) {
      ev.preventDefault();
      setCommentData(ev.target)
      $publishAccountModal.foundation("open");
    }
  };
  const handleCommentForms = (wrapper) => {
    wrapper.querySelectorAll("form").forEach((commentForm) => {
      commentForm.querySelectorAll("button[type='submit'], input[type='submit']").forEach((button) => {
        button.removeEventListener("click", handleCommentAction);
        button.addEventListener("click", handleCommentAction);
      });
    });
  };

  document.querySelectorAll("[data-decidim-comments]").forEach((commentsWrapper) => {
    const component = $(commentsWrapper).data("comments");
    const originalAddReply = component.addReply.bind(component);
    const originalAddThread = component.addThread.bind(component);

    component.addReply = (...args) => {
      originalAddReply(...args)
      handleCommentForms(commentsWrapper);
    };
    component.addThread = (...args) => {
      originalAddThread(...args);
      handleCommentForms(commentsWrapper);
    };
    handleCommentForms(commentsWrapper);
  });
  const removePublishModal = () => {
    document.querySelectorAll("[data-open='publishAccountModal']").forEach((item) => {
      item.removeEventListener("click", setFormValues)
      let dataPrivacy = JSON.parse(item.getAttribute("data-privacy"));
      if (!dataPrivacy) {
        return;
      }

      if (dataPrivacy.open && dataPrivacy.openUrl) {
        item.setAttribute("data-open", dataPrivacy.open);
        $(item).data("open", dataPrivacy.open);
        item.setAttribute("data-open-url", dataPrivacy.openUrl);
        $(item).data("open-url", dataPrivacy.openUrl);
        item.removeAttribute("data-privacy");
      } else {
        item.removeAttribute("data-open");
      }
    })
    $publishAccountModal.foundation("close");
    $publishAccountModal.remove();
    $publishAccountModal = null;
  }

  const handleCommentSubmission = () => {
    removePublishModal();
    $("[data-popup-comment-id]").click();
  }
  const handleAuthorizationPopup = (el) => {
    removePublishModal();
    $(`#${el}`).click();
  }

  $(".update-privacy").closest("form").on("ajax:complete", (el) => {
    let redirectDestination =  el.target.getAttribute("data-redirect-url");
    let dataTriggeringPrivacy = el.target.getAttribute("data-triggering-privacy");
    if (redirectDestination) {
      window.location.href = el.target.getAttribute("data-redirect-url");
    } else if (dataTriggeringPrivacy) {
      handleAuthorizationPopup(dataTriggeringPrivacy);
    } else {
      handleCommentSubmission();
    }
  });
});

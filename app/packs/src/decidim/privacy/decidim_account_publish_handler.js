$(() => {
  let $anonymityModal = $("#anonymityModal");
  if ($anonymityModal.length < 1) {
    $anonymityModal = null;
  }

  let $publishAccountModal = $("#publishAccountModal");
  if ($publishAccountModal.length < 1) {
    $publishAccountModal = null;
  }

  let triggeredLoginElement = localStorage.getItem("loginTriggeringElement")
  // We capture the element which has a login modal attached with it to check after login if they have the publish condition after they
  // have logged in. These elements might or might not have the public account requirement to show the modal.
  const setFormValues =  (ev) => {
    if (!$publishAccountModal) {
      return
    }

    if ($anonymityModal) {
      document.querySelector("#publicize").addEventListener("click", () => {
        window.Decidim.currentDialogs.anonymityModal.close();
        window.Decidim.currentDialogs.publishAccountModal.open();
      });

      document.querySelector("#anonymize").addEventListener("click", () => {
        let anonymityForm = document.getElementById("update-anonymity-publish-form");
        anonymityForm.requestSubmit();
      })
    }

    let redirectUrl = ev.currentTarget.dataset.redirectUrl
    let dataPrivacy = ev.currentTarget.dataset.dialogPrivacy || "{}"

    if (dataPrivacy && dataPrivacy !== "{}") {
      if ($anonymityModal) {
        $anonymityModal.find("form").attr("data-triggering-privacy", ev.currentTarget.id)
      }

      $publishAccountModal.find("form").attr("data-triggering-privacy", ev.currentTarget.id)
    } else {
      if ($anonymityModal) {
        $anonymityModal.find("form").attr("data-redirect-url", redirectUrl)
      }

      $publishAccountModal.find("form").attr("data-redirect-url", redirectUrl)
    }
  }

  if ($publishAccountModal) {
    if (triggeredLoginElement) {
      let element = document.getElementById(triggeredLoginElement);

      if (element) {
        if ($anonymityModal) {
          window.Decidim.currentDialogs.anonymityModal.open();
          $anonymityModal.find("form").attr("data-redirect-url", element.getAttribute("data-redirect-url"));
        }

        window.Decidim.currentDialogs.publishAccountModal.open();
        $publishAccountModal.find("form").attr("data-redirect-url", element.getAttribute("data-redirect-url"));

        localStorage.removeItem("loginTriggeringElement");
      }
    }

    if ($anonymityModal) {
      document.querySelectorAll("[data-dialog-open='anonymityModal']").forEach((el) => {
        el.addEventListener("click", setFormValues);
      });
    } else {
      document.querySelectorAll("[data-dialog-open='publishAccountModal']").forEach((el) => {
        el.addEventListener("click", setFormValues);
      });
    }
  }

  document.querySelectorAll("[data-dialog-open='loginModal']").forEach((el) => {
    el.addEventListener("click", (ev) => {
      localStorage.setItem("loginTriggeringElement", ev.target.id);
    })
  });

  $("#loginModal").on("close.dialog", () => {
    localStorage.removeItem("loginTriggeringElement");
  });

  const handleAnonymize = () => {
    let anonymityForm = document.getElementById("update-anonymity-form");
    anonymityForm.requestSubmit();
  };

  const handleModals = () => {
    window.Decidim.currentDialogs.anonymityModal.close();
    document.querySelector("#anonymize").addEventListener("click", handleAnonymize);

    window.Decidim.currentDialogs.publishAccountModal.open();
  };

  if ($anonymityModal) {
    $("#anonymityModal").on("close.dialog", () => {
      const publicizeButton = $anonymityModal.find("#publicize").get(0);

      if (publicizeButton) {
        publicizeButton.removeEventListener("click", handleModals);
      }
    });
  };

  $("#publishAccountModal").on("close.dialog", () => {
    const anonymizeButton = $publishAccountModal.find("#anonymize").get(0);

    if (anonymizeButton) {
      anonymizeButton.removeEventListener("click", handleAnonymize);
    }
  });

  const setCommentData = (buttonElement) => {
    buttonElement.setAttribute("data-popup-comment-id", buttonElement.closest("form").id)
  }

  const handleCommentAction = (ev) => {
    if ($anonymityModal) {
      ev.preventDefault();
      setCommentData(ev.target);
      document.querySelector("#publicize").addEventListener("click", handleModals);

      window.Decidim.currentDialogs.anonymityModal.open();
    } else if ($publishAccountModal) {
      ev.preventDefault();
      setCommentData(ev.target);

      window.Decidim.currentDialogs.publishAccountModal.open();
    }
  }

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
  })

  const removePrompt = () => {
    if ($anonymityModal) {
      document.querySelectorAll("[data-dialog-open='anonymityModal']").forEach((item) => {
        item.removeEventListener("click", setFormValues);
        let dataPrivacy = JSON.parse(item.getAttribute("data-privacy"));

        if (!dataPrivacy) {
          return;
        }

        if (dataPrivacy.open && dataPrivacy.openUrl) {
          item.setAttribute("data-dialog-open", dataPrivacy.open);
          $(item).data("open", dataPrivacy.open);
          item.setAttribute("data-open-url", dataPrivacy.openUrl);
          $(item).data("open-url", dataPrivacy.openUrl);
          item.removeAttribute("data-privacy");
        } else {
          item.removeAttribute("data-dialog-open");
        }
      })

      window.Decidim.currentDialogs.anonymityModal.close();
      $anonymityModal.remove();
      $anonymityModal = null;
      window.Decidim.currentDialogs.publishAccountModal.close();
      $publishAccountModal.remove();
      $publishAccountModal = null;
    } else {
      document.querySelectorAll("[data-dialog-open='publishAccountModal']").forEach((item) => {
        item.removeEventListener("click", setFormValues);
        let dataPrivacy = JSON.parse(item.getAttribute("data-privacy"));
        if (!dataPrivacy) {
          return;
        }

        if (dataPrivacy.open && dataPrivacy.openUrl) {
          item.setAttribute("data-dialog-open", dataPrivacy.open);
          $(item).data("open", dataPrivacy.open);
          item.setAttribute("data-open-url", dataPrivacy.openUrl);
          $(item).data("open-url", dataPrivacy.openUrl);
          item.removeAttribute("data-privacy");
        } else {
          item.removeAttribute("data-dialog-open");
        }
      })

      window.Decidim.currentDialogs.publishAccountModal.close();
      $publishAccountModal.remove();
      $publishAccountModal = null;
    }
  }


  const handleCommentSubmission = () => {
    removePrompt();
    $("[data-popup-comment-id]").click();
  }
  const handleAuthorizationPopup = (el) => {
    removePrompt();
    $(`#${el}`).click();
  }

  if ($anonymityModal) {
    $("#update-anonymity-publish-form").closest("form").on("ajax:complete", (el) => {
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
  }

  $("#update-privacy-form").closest("form").on("ajax:complete", (el) => {
    if ($anonymityModal) {
      let anonymityForm = document.getElementById("update-anonymity-publish-form");
      let anonymityHiddenField = document.getElementById("anonymity-hidden-field");

      anonymityHiddenField.value = false;
      anonymityForm.requestSubmit();
    }

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

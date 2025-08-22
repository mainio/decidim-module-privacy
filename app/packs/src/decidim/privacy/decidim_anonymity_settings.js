$(() => {
  let privacyMessagingText = document.getElementById("toggle-privacy-messaging");
  let accountPublicity = document.getElementById("user_published_at");
  let anonymity = document.getElementById("user_anonymity");

  const switchStatus = (sourceCheckbox, targetCheckbox) => {
    sourceCheckbox.addEventListener("change", () => {
      if (sourceCheckbox.checked) {
        targetCheckbox.checked = false;
        if (sourceCheckbox === accountPublicity) {
          privacyMessagingText.classList.remove("hide");
        } else {
          privacyMessagingText.classList.add("hide");
        }
      }
    });
  };

  switchStatus(accountPublicity, anonymity);
  switchStatus(anonymity, accountPublicity);
});

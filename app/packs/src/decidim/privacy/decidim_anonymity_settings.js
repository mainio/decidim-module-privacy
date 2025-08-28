$(() => {
  let privacyMessagingText = document.getElementById("toggle-privacy-messaging");
  let accountPublicity = document.getElementById("published_at");
  let anonymity = document.getElementById("anonymity");

  const switchStatus = (sourceCheckbox, targetCheckbox) => {
    sourceCheckbox.addEventListener("change", () => {
      if (sourceCheckbox.checked) {
        targetCheckbox.checked = false;
        if (sourceCheckbox === accountPublicity) {
          privacyMessagingText.style.display = "block";
        } else {
          privacyMessagingText.style.display = "none";
        }
      }
    })
  };

  switchStatus(accountPublicity, anonymity);
  switchStatus(anonymity, accountPublicity);
});

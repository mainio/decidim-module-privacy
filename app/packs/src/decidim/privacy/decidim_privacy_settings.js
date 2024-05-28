$(() => {
  let privacyMessagingText = document.getElementById("toggle-privacy-messaging");
  let accountPublicity = document.getElementById("published_at");

  if (accountPublicity && accountPublicity.dataset.publicity === "true") {
    privacyMessagingText.style.display = "block";
  } else {
    privacyMessagingText.style.display = "none";
  }

  const toggleVisibility = () => {
    if (privacyMessagingText.style.display === "none"){
      privacyMessagingText.style.display = "block";
    } else {
      privacyMessagingText.style.display = "none";
    }
  };

  accountPublicity.addEventListener("click", () => {
    toggleVisibility();
  });
});

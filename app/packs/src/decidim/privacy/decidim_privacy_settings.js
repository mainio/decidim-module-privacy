$(() => {
  let privacyMessagingText = document.getElementById("toggle-privacy-messaging");
  let accountPublicity = document.getElementById("user_published_at");

  if (accountPublicity && accountPublicity.dataset.publicity === "true") {
    privacyMessagingText.classList.remove("hide");
  }
  const toggleVisibility = () => {
    privacyMessagingText.classList.toggle("hide");
  };

  accountPublicity.addEventListener("click", () => {
    toggleVisibility();
  });
});

$(() => {
  let privacyMessagingText = document.getElementById("toggle-privacy-messaging");
  let PrivacyMessaging = document.getElementById("user_published_at");
  if (PrivacyMessaging && PrivacyMessaging.value !== "1") {
    privacyMessagingText.classList.add("hide");
  }
  const toggleVisibility = () => {
    privacyMessagingText.classList.toggle("hide");
  };

  PrivacyMessaging.addEventListener("click", () => {
    toggleVisibility();
  });
});

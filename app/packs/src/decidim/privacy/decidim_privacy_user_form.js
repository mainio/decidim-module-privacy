/**
 * The following changes are related to "Ask old password for changing email/password(PR #11737)"
 * These changes should be removed once it has been backported to v.27
 */
/**
 * Initializes the edit account form to control the password field elements
 * which should only be required when they are visible.
 *
 * @returns {void}
 */
const initializeAccountForm = () => {

  const editUserForm = document.querySelector("form.edit_user");
  if (!editUserForm ) {
    return
  }
  const passwordChange = editUserForm.querySelector("#passwordChange");
  const passwordFields = document.querySelector(".user-password").querySelectorAll("input[type='password']");
  const oldPasswordField = editUserForm.querySelector("#old_password_field");
  const emailField = document.querySelector("input[type='email']");
  if (!passwordChange || passwordFields.length < 1 || !oldPasswordField || !emailField) {
    return;
  }

  const originalEmail = emailField.dataset.original;
  let emailChanged = originalEmail !== emailField.value;
  let newPwVisible = false;
  let oldPasswordVisible = false;

  // Foundation uses jQuery so these have to be bound using jQuery and the
  // attribute value needs to be set through jQuery.
  const togglePasswordFieldValidators = () => {
    $(passwordFields).attr("required", !newPwVisible);

    if (!newPwVisible) {
      passwordFields.forEach((field) => (field.value = ""));
    }
    newPwVisible = !newPwVisible;
    toggleOldPassword();
  }

  $(passwordChange).on("on.zf.toggler", () => {
    togglePasswordFieldValidators();
  });

  const toggleOldPassword = () => {
    console.log("toggling old password");
    let oldPasswordInput = oldPasswordField.querySelector("input[type='password']");
    if (newPwVisible && oldPasswordVisible) {
      console.log("not toggling old password")
      return
    }

    if ($(oldPasswordField).hasClass("hide")){
      $(oldPasswordField).removeClass("hide")
    } else {
      $(oldPasswordField).addClass("hide")
    }
    $(oldPasswordInput).attr("require", oldPasswordVisible);
    oldPasswordVisible = !oldPasswordVisible;
    console.log("old password visible: ", oldPasswordVisible)
  }

  $(passwordChange).on("off.zf.toggler", () => {
    togglePasswordFieldValidators();
  });

  emailField.addEventListener("change", () => {
    emailChanged = emailField.value !== originalEmail;
    toggleOldPassword();
  });
};

/**
 * Since the delete account has a modal to confirm it we need to copy the content of the
 * reason field to the hidden field in the form inside the modal.
 *
 * @return {void}
 */
const initializeDeleteAccount = () => {
  const $deleteAccountForm = $(".delete-account");
  const $deleteAccountModalForm = $(".delete-account-modal");

  if ($deleteAccountForm.length < 1) {
    return;
  }

  const $openModalButton = $(".open-modal-button");
  const $modal = $("#deleteConfirm");

  $openModalButton.on("click", (event) => {
    try {
      const reasonValue = $deleteAccountForm.find("textarea#delete_account_delete_reason").val();
      $deleteAccountModalForm.find("input#delete_account_delete_reason").val(reasonValue);
      $modal.foundation("open");
    } catch (error) {
      console.error(error); // eslint-disable-line no-console
    }

    event.preventDefault();
    event.stopPropagation();
    return false;
  });
};

$(() => {
  initializeAccountForm();
  initializeDeleteAccount();
});

# frozen_string_literal: true

require "spec_helper"

describe "Account", type: :system do
  let(:user) { create(:user, :confirmed, password: password, password_confirmation: password) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "account links" do
    before { visit decidim.root_path }

    context "when user private" do
      context "when opening user menu" do
        it "does not have 'my public profile' link" do
          click_link user.name
          expect(page).not_to have_link("My public profile")
        end
      end
    end

    context "when user public" do
      context "when opening user menu" do
        it "has 'my public profile' link" do
          user.update(published_at: Time.current)

          refresh
          click_link user.name
          expect(page).to have_link("My public profile")
        end
      end
    end
  end

  describe "navigation" do
    before do
      visit decidim.root_path

      within_user_menu do
        find("a", text: "account").click
      end
    end

    it "shows the account form when clicking on the menu" do
      expect(page).to have_css("h1", text: "Participant settings - My account")

      expect(page).to have_css("form.edit_user")
    end

    it "shows the privacy settings page" do
      within "#user-settings-tabs" do
        click_link "Privacy settings"
      end

      expect(page).to have_css("h1", text: "Participant settings - Privacy settings")
    end

    it "shows the notification settings page" do
      within "#user-settings-tabs" do
        click_link "Notifications settings"
      end

      expect(page).to have_css("h1", text: "Participant settings - Notifications settings")
    end

    it "shows the my interests page" do
      within "#user-settings-tabs" do
        click_link "My interests"
      end

      expect(page).to have_css("h1", text: "Participant settings - My interests")
    end

    it "shows the my data page" do
      within "#user-settings-tabs" do
        click_link "My data"
      end

      expect(page).to have_css("h1", text: "Participant settings - My data")
    end

    it "shows the delete my account page" do
      within "#user-settings-tabs" do
        click_link "Delete my account"
      end

      expect(page).to have_css("h1", text: "Participant settings - Delete my account")
    end
  end

  context "when updating email address" do
    let(:pending_email) { "foo@bar.com" }

    before { visit decidim.account_path }

    context "when typing new email" do
      before do
        within "form.edit_user" do
          fill_in "Your email", with: pending_email
          find("*[type=submit]").click
        end
      end

      it "toggles the current password" do
        expect(page).to have_content("In order to confirm the changes to your account, please provide your current password.")
        expect(find("#user_old_password")).to be_visible
        expect(page).to have_content "Current password"
        expect(page).not_to have_content "Password"
      end

      it "renders the old password with error" do
        within "form.edit_user" do
          find("*[type=submit]").click
        end

        within "form.new_user" do
          fill_in :user_old_password, with: "wrong password"
          find("*[type=submit]").click
        end
        within ".flash.alert" do
          expect(page).to have_content "There was a problem updating your account."
        end
        find("#old_password_field").click
        within "#old_password_field" do
          expect(page).to have_css('[role="alert"]', text: "is invalid")
        end
      end
    end

    context "when correct old password" do
      before do
        within "form.edit_user" do
          fill_in "Your email", with: pending_email
          find("*[type=submit]").click
          fill_in :user_old_password, with: password

          perform_enqueued_jobs { find("*[type=submit]").click }
        end

        within_flash_messages do
          expect(page).to have_content("You'll receive an email to confirm your new email address.")
        end
      end

      after do
        clear_enqueued_jobs
      end

      it "tells user to confirm new email" do
        expect(page).to have_content("Email change verification")
        expect(page).to have_selector("#user_email[readonly='readonly']")
        expect(page).to have_content("You'll receive an email to confirm your new email address.")
      end

      it "resend confirmation" do
        within "#email-change-pending" do
          click_link "Send again"
        end
        expect(page).to have_content("Confirmation email resent successfully to #{pending_email}")
        perform_enqueued_jobs
        perform_enqueued_jobs

        expect(emails.count).to eq(2)
        visit last_email_link
        expect(page).to have_content("Your email address has been successfully confirmed")
      end

      it "cancels the email change" do
        expect(Decidim::User.unscoped.find(user.id).unconfirmed_email).to eq(pending_email)
        within "#email-change-pending" do
          click_link "cancel"
        end

        expect(page).to have_content("Email change cancelled successfully")
        expect(page).not_to have_content("Email change verification")
        expect(Decidim::User.unscoped.find(user.id).unconfirmed_email).to be_nil
      end
    end
  end

  describe "when updating password" do
    let!(:encrypted_password) { user.encrypted_password }
    let(:new_password) { "decidim1234567890" }

    before do
      visit decidim.account_path
      click_button "Change password"
    end

    it "toggles old and new password fields" do
      within "form.edit_user" do
        expect(page).to have_content("must not be too common (e.g. 123456) and must be different from your nickname and your email.")
        expect(page).to have_field("user[password]", with: "", type: "password")
        expect(page).to have_field("user[password_confirmation]", with: "", type: "password")
        expect(page).to have_field("user[old_password]", with: "", type: "password")
        click_button "Change password"
        expect(page).not_to have_field("user[password]", with: "", type: "password")
        expect(page).not_to have_field("user[password_confirmation]", with: "", type: "password")
        expect(page).not_to have_field("user[old_password]", with: "", type: "password")
      end
    end

    it "shows fields if password is wrong" do
      within "form.edit_user" do
        fill_in "Password", with: new_password
        fill_in "user[password_confirmation]", with: new_password
        fill_in "Current password", with: "wrong password12345"
        find("*[type=submit]").click
      end
      expect(page).to have_content("There was a problem updating your account.")
      expect(page).to have_field("user[password]", with: "", type: "password")
      expect(page).to have_content("is invalid")
    end

    it "changes the password with correct password" do
      within "form.edit_user" do
        fill_in "Password", with: new_password
        fill_in "user[password_confirmation]", with: new_password
        fill_in "Current password", with: password
        find("*[type=submit]").click
      end
      within_flash_messages do
        expect(page).to have_content("successfully")
      end
      expect(user.reload.encrypted_password).not_to eq(encrypted_password)
      expect(page).not_to have_field("user[password]", with: "", type: "password")
      expect(page).not_to have_field("user[old_password]", with: "", type: "password")
    end
  end

  context "when visiting 'privacy settings' page" do
    context "when private account" do
      it "does not show 'private messaging' settings" do
        visit "/privacy_settings"

        expect(page).to have_content("Enable public profile")
        expect(page.find("#user_published_at", visible: :hidden)).not_to be_checked
        expect(page).not_to have_content("Private messaging")
        expect(page).not_to have_content("Enable private messaging")
        expect(page).not_to have_content("Allow anyone to send me a direct message, even if I do not follow them.")
      end
    end

    context "when publishing your account" do
      it "shows 'private messaging' settings" do
        visit "/privacy_settings"

        expect(page).to have_content("Enable public profile")
        expect(page.find("#user_published_at", visible: :hidden)).not_to be_checked
        find("label[for='user_published_at']").click
        expect(page).to have_content("Private messaging")
        expect(page).to have_content("Enable private messaging")
        expect(page).to have_content("Allow anyone to send me a direct message, even if I do not follow them.")
      end
    end

    context "when changing settings to opposite of default values" do
      it "saves the settings for the user" do
        visit "/privacy_settings"

        expect(user.published_at).to be_nil
        expect(user.allow_private_messaging).to be(true)
        expect(user.direct_message_types).to eq("all")

        expect(page.find("#user_published_at", visible: :hidden)).not_to be_checked

        find("label[for='user_published_at']").click
        expect(page.find("#user_published_at", visible: :hidden)).to be_checked

        expect(page.find("#user_allow_private_messaging", visible: :hidden)).to be_checked
        expect(page.find("#user_allow_public_contact", visible: :hidden)).to be_checked

        find("label[for='user_allow_private_messaging']").click
        expect(page.find("#user_allow_private_messaging", visible: :hidden)).not_to be_checked
        find(".allow_public_contact").click
        expect(page.find("#user_allow_public_contact", visible: :hidden)).not_to be_checked
        click_button "Save privacy settings"
        expect(page).to have_content("Your privacy settings were successfully updated.")

        user.reload
        expect(user.published_at).to be_present
        expect(user.allow_private_messaging).to be(false)
        expect(user.direct_message_types).to eq("followed-only")
      end
    end
  end

  context "when on the notifications settings page" do
    before do
      visit decidim.notifications_settings_path
    end

    it "updates the user's notifications" do
      within ".switch.newsletter_notifications" do
        page.find(".switch-paddle").click
      end

      within "form.edit_user" do
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end
    end

    context "when the user is an admin" do
      let!(:user) { create(:user, :confirmed, :admin, password: password, password_confirmation: password) }

      before do
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "updates the administrator's notifications" do
        within ".switch.email_on_moderations" do
          page.find(".switch-paddle").click
        end

        within ".switch.notification_settings" do
          page.find(".switch-paddle").click
        end

        within "form.edit_user" do
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end
      end
    end
  end
end

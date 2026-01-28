# frozen_string_literal: true

require "spec_helper"

describe "Account" do
  let(:user) { create(:user, :confirmed, password:) }
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
          find_by_id("trigger-dropdown-account").click
          expect(page).to have_no_link("My public profile")
        end
      end
    end

    context "when user public" do
      context "when opening user menu" do
        it "has 'my public profile' link" do
          user.update(published_at: Time.current)

          refresh
          find_by_id("trigger-dropdown-account").click
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

    it "shows the notification settings page" do
      within "#dropdown-menu-profile" do
        click_on "Notifications settings"
      end

      expect(page).to have_css("h1", text: "Participant settings")
      expect(page).to have_css("label", text: "I want to get notifications about")
    end

    it "shows the privacy settings page" do
      within "#dropdown-menu-profile" do
        click_on "Privacy settings"
      end

      expect(page).to have_css("h1", text: "Participant settings")
      expect(page).to have_css("h2", text: "Profile publicity")
    end

    it "shows the my interests page" do
      within "#dropdown-menu-profile" do
        click_on "My interests"
      end

      expect(page).to have_css("h1", text: "Participant settings")
      expect(page).to have_css("span", text: "MY INTERESTS")
    end

    it "shows the my data page" do
      within "#dropdown-menu-profile" do
        click_on "My data"
      end

      expect(page).to have_css("h1", text: "Participant settings")
      expect(page).to have_css("span", text: "DOWNLOAD THE DATA")
    end

    it "shows the delete my account page" do
      within "#dropdown-menu-profile" do
        click_on "Delete my account"
      end

      expect(page).to have_css("h1", text: "Participant settings")
      expect(page).to have_button("Delete my account")
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
        expect(find_by_id("user_old_password")).to be_visible
        expect(page).to have_content "Current password"
        expect(page).to have_no_content "Password"
      end

      it "renders the old password with error" do
        within "form.edit_user" do
          find("*[type=submit]").click
          fill_in :user_old_password, with: "wrong password"
          find("*[type=submit]").click
        end
        within ".flash.alert" do
          expect(page).to have_content "There was a problem updating your account."
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
          expect(page).to have_content(
            "Your account was successfully updated. You will receive an email to confirm your new email address."
          )
        end
      end

      after do
        clear_enqueued_jobs
      end

      it "tells user to confirm new email" do
        expect(page).to have_content("Email change verification")
        expect(page).to have_css("#user_email[disabled='disabled']")
        expect(page).to have_content(
          "Your account was successfully updated. You will receive an email to confirm your new email address."
        )
      end

      it "resend confirmation" do
        within "#email-change-pending" do
          click_on "Send again"
        end
        expect(page).to have_content("Confirmation email resent successfully to #{pending_email}")
        perform_enqueued_jobs

        expect(emails.count).to eq(2)
        expect(emails[0].subject).to eq("Confirmation instructions")
        expect(emails[0].to).to eq([pending_email])
        expect(emails[1].subject).to eq("Your account was updated")
        expect(emails[1].to).to eq([user.email])

        confirm_link = Nokogiri::HTML(email_body(emails[0])).css("table.content a").last["href"]
        visit confirm_link
        expect(page).to have_content("Your email address has been successfully confirmed")
      end

      it "cancels the email change" do
        expect(Decidim::User.unscoped.find(user.id).unconfirmed_email).to eq(pending_email)
        within "#email-change-pending" do
          click_on "cancel"
        end

        expect(page).to have_content("Email change cancelled successfully")
        expect(page).to have_no_content("Email change verification")
        expect(Decidim::User.unscoped.find(user.id).unconfirmed_email).to be_nil
      end
    end
  end

  describe "when updating password" do
    let!(:encrypted_password) { user.encrypted_password }
    let(:new_password) { "decidim1234567890" }

    before do
      visit decidim.account_path
      click_on "Change password"
    end

    it "toggles old and new password fields" do
      within "form.edit_user" do
        expect(page).to have_content("must not be too common (e.g. 123456) and must be different from your nickname and your email.")
        expect(page).to have_field("user[password]", with: "", type: "password")
        expect(page).to have_field("user[old_password]", with: "", type: "password")
        click_on "Change password"
        expect(page).to have_no_field("user[password]", with: "", type: "password")
        expect(page).to have_no_field("user[old_password]", with: "", type: "password")
      end
    end

    it "shows fields if password is wrong" do
      within "form.edit_user" do
        fill_in "Password", with: new_password
        fill_in "Current password", with: "wrong password12345"
        find("*[type=submit]").click
      end
      expect(page).to have_content("There was a problem updating your account.")
      expect(page).to have_content("is invalid")
    end

    it "changes the password with correct password" do
      within "form.edit_user" do
        fill_in "Password", with: new_password
        fill_in "Current password", with: password
        find("*[type=submit]").click
      end
      within_flash_messages do
        expect(page).to have_content("successfully")
      end
      expect(user.reload.encrypted_password).not_to eq(encrypted_password)
      expect(page).to have_no_field("user[password]", with: "", type: "password")
      expect(page).to have_no_field("user[old_password]", with: "", type: "password")
    end
  end

  context "when visiting 'privacy settings' page" do
    context "when private account" do
      it "does not show 'private messaging' settings" do
        visit "/privacy_settings"

        expect(page).to have_content("Enable public profile")
        expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked
        expect(page).to have_no_content("Private messaging")
        expect(page).to have_no_content("Enable private messaging")
        expect(page).to have_no_content("Allow anyone to send me a direct message, even if I do not follow them.")
      end
    end

    context "when publishing your account" do
      it "shows 'private messaging' settings" do
        visit "/privacy_settings"

        expect(page).to have_content("Enable public profile")
        expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked
        find("label[for='published_at']").click
        expect(page).to have_content("Private messaging")
        expect(page).to have_content("Enable private messaging")
        expect(page).to have_content("Allow public contacting")
      end
    end

    context "when changing settings to opposite of default values" do
      it "saves the settings for the user" do
        visit "/privacy_settings"

        expect(user.published_at).to be_nil
        expect(user.allow_private_messaging).to be(true)
        expect(user.direct_message_types).to eq("all")

        expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked

        find("label[for='published_at']").click
        expect(page.find_by_id("published_at", visible: :hidden)).to be_checked

        expect(page.find_by_id("allow_private_messaging", visible: :hidden)).to be_checked
        expect(page.find_by_id("allow_public_contact", visible: :hidden)).to be_checked

        find("label[for='allow_private_messaging']").click
        expect(page.find_by_id("allow_private_messaging", visible: :hidden)).not_to be_checked
        within "label[for='allow_public_contact']" do
          find(".toggle__switch-toggle-content").click
        end
        expect(page.find_by_id("allow_public_contact", visible: :hidden)).not_to be_checked
        click_on "Save privacy settings"
        expect(page).to have_content("Your privacy settings were successfully updated.")

        user.reload
        expect(user.published_at).to be_present
        expect(user.allow_private_messaging).to be(false)
        expect(user.direct_message_types).to eq("followed-only")
      end
    end

    context "when anonymity enabled", :anonymity do
      context "when anonymous account" do
        let(:user) { create(:user, :anonymous, :confirmed, password:, password_confirmation: password) }

        it "disables publicity", :anonymity do
          visit "/privacy_settings"

          expect(page.find_by_id("anonymity", visible: :hidden)).to be_checked
          expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked
        end

        context "when switching anonymity off" do
          it "keeps anonymity and publicity off" do
            visit "/privacy_settings"
            expect(page.find_by_id("anonymity", visible: :hidden)).to be_checked
            expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked

            find("label[for='anonymity']").click

            expect(page.find_by_id("anonymity", visible: :hidden)).not_to be_checked
            expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked
          end
        end

        context "when switching publicity on" do
          it "turns anonymity off" do
            visit "/privacy_settings"
            expect(page.find_by_id("anonymity", visible: :hidden)).to be_checked
            expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked

            find("label[for='published_at']").click

            expect(page.find_by_id("anonymity", visible: :hidden)).not_to be_checked
            expect(page.find_by_id("published_at", visible: :hidden)).to be_checked
          end
        end

        context "when publicity enabled and switching to anonymous" do
          let(:user) { create(:user, :published, :confirmed, password:, password_confirmation: password) }

          it "turns publicity off" do
            visit "/privacy_settings"
            expect(page.find_by_id("anonymity", visible: :hidden)).not_to be_checked
            expect(page.find_by_id("published_at", visible: :hidden)).to be_checked

            find("label[for='anonymity']").click

            expect(page.find_by_id("anonymity", visible: :hidden)).to be_checked
            expect(page.find_by_id("published_at", visible: :hidden)).not_to be_checked
          end
        end
      end
    end
  end

  context "when on the notifications settings page" do
    before do
      visit decidim.notifications_settings_path
    end

    it "updates the user's notifications" do
      find("label[for='newsletter_notifications']").click

      click_on "Save changes"

      within_flash_messages do
        expect(page).to have_content("successfully")
      end
    end

    context "when the user is an admin" do
      let!(:user) { create(:user, :confirmed, :admin, password:) }

      before do
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "updates the administrator's notifications" do
        find("label[for=\"email_on_moderations\"]").click
        find("label[for=\"user_notification_settings[close_meeting_reminder]\"]").click

        click_on "Save changes"

        within_flash_messages do
          expect(page).to have_content("successfully")
        end
      end
    end
  end
end

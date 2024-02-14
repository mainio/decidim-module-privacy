# frozen_string_literal: true

require "spec_helper"

describe "UpdateAccount", type: :system do
  let(:user) { create(:user, :confirmed, password: password, password_confirmation: password) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.account_path
  end

  describe "when update password" do
    let!(:encrypted_password) { user.encrypted_password }
    let(:new_password) { "decidim1234567890" }

    before do
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
      expect(page).to have_field("user[password]", with: "decidim1234567890", type: "password")
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

  context "when update email" do
    let(:pending_email) { "foo@bar.com" }

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
          fill_in :user_old_password, with: "wrong password"
          find("*[type=submit]").click
        end
        within ".flash.alert" do
          expect(page).to have_content "There was a problem updating your account."
        end
        within "#old_password_field" do
          expect(page).to have_content "is invalid"
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
        expect(page).to have_selector("#user_email[disabled='disabled']")
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
end

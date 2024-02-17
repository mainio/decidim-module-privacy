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

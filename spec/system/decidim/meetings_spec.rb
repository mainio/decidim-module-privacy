# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Meetings" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when anonymity disabled" do
    context "when trying to create a new meeting" do
      let!(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }

      it "gives you a publicity popup for consent, which has to be accepted in order to proceed" do
        visit_component

        expect(page).to have_content("New meeting")
        click_link "New meeting"

        expect(page).to have_content("Make your profile public")
        expect(page).to have_content(
          "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
        )

        find_by_id("publish_account_agree_public_profile").check

        click_button "Make your profile public"

        expect(page).to have_content("Create Your Meeting")
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
      end

      context "when trying to visit url for creating a new meeting" do
        it "renders a custom page with a prompt which has to be accepted in order to proceed" do
          visit new_meeting_path(component)

          expect(page).to have_content("Public profile is required for this action".upcase)
          expect(page).to have_content("You are trying to access a page which requires your profile to be public. Making your profile public allows other participants to see information about you.")
          expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

          click_button "Publish your profile"

          find_by_id("publish_account_agree_public_profile").check

          click_button "Make your profile public"

          expect(page).to have_content("Create Your Meeting")
          expect(page).to have_content("Title")
          expect(page).to have_content("Description")
        end
      end
    end

    context "when user has created a meeting" do
      let!(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
      let!(:meeting) { create(:meeting, :online, :not_official, :published, registrations_enabled: true, author: user, component:) }

      context "when user tries to edit meeting" do
        context "when user private" do
          it "doesn't render edit button" do
            visit_component
            click_link meeting.title["en"]

            expect(page).to have_no_link("Edit")
          end
        end
      end
    end
  end

  context "when anonymity enabled", :anonymity do
    context "when trying to create a new meeting" do
      let!(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }

      it "gives you an anonymity popup for consent, which has to be accepted in order to proceed" do
        visit_component

        expect(page).to have_content("New meeting")
        click_link "New meeting"

        expect(page).to have_content("Profile publicity")
        expect(page).to have_content(
          "Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others."
        )

        click_button "Continue anonymous"

        expect(page).to have_content("Create Your Meeting")
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
      end

      context "when trying to visit url for creating a new meeting" do
        it "renders a custom page with a prompt which has to be accepted in order to proceed" do
          visit new_meeting_path(component)

          expect(page).to have_content("Your profile is anonymous".upcase)
          expect(page).to have_content("You are entering a page anonymously. If you want other participants to see information about you, you can also make your profile public.")
          expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

          click_button "Continue"

          click_button "Continue anonymous"

          expect(page).to have_content("Create Your Meeting")
          expect(page).to have_content("Title")
          expect(page).to have_content("Description")
        end
      end
    end

    context "when user has created a meeting" do
      let!(:user) { create(:user, :anonymous, :confirmed, organization:) }
      let!(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
      let!(:meeting) { create(:meeting, :online, :not_official, :published, registrations_enabled: true, author: user, component:) }

      context "when user tries to edit meeting" do
        context "when user anonymous" do
          it "renders edit button" do
            visit_component
            click_link meeting.title["en"]

            expect(page).to have_link("Edit")
          end
        end
      end
    end
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  def new_meeting_path(component)
    Decidim::EngineRouter.main_proxy(component).new_meeting_path(component.id)
  end
end

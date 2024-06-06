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

  context "when trying to create a new meeting" do
    let!(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component

      expect(page).to have_content("New meeting")
      click_on "New meeting"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
      )

      find_by_id("publish_account_agree_public_profile").check

      click_on "Make your profile public"

      expect(page).to have_content("CREATE YOUR MEETING")
      expect(page).to have_content("Title")
      expect(page).to have_content("Description")
    end

    context "when trying to visit url for creating a new meeting" do
      it "renders a custom page with a prompt which has to be accepted in order to proceed" do
        visit new_meeting_path(component)

        expect(page).to have_content("PUBLIC PROFILE IS REQUIRED FOR THIS ACTION")
        expect(page).to have_content("You are trying to access a page which requires your profile to be public. Making your profile public allows other participants to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

        click_on "Publish your profile"

        find_by_id("publish_account_agree_public_profile").check

        click_on "Make your profile public"

        expect(page).to have_content("CREATE YOUR MEETING")
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
          click_on meeting.title["en"]

          expect(page).to have_no_link("Edit")
        end
      end
    end

    context "when user joins meeting as private and allows attendance publicly" do
      it "does not show user's name under 'attending participants'" do
        join_meeting

        within "#list-of-public-participants" do
          expect(page).to have_no_content(user.name)
        end
      end
    end

    context "when user joins meeting as public and allows attendance publicly" do
      it "shows user's name under 'attending participants'" do
        user.update(published_at: Time.current)
        join_meeting

        within "#list-of-public-participants" do
          expect(page).to have_content(user.name)
        end
      end
    end
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  def join_meeting
    visit_meeting
    expect(page).to have_link("Register")
    find("a", text: "Register").click
    expect(page).to have_content("Show my attendance publicly")
    check "public_participation"
    check "questionnaire_tos_agreement"
    click_on "Submit"
    within ".confirm-modal-footer" do
      find("[data-confirm-ok]").click
    end
  end

  def new_meeting_path(component)
    Decidim::EngineRouter.main_proxy(component).new_meeting_path(component.id)
  end
end

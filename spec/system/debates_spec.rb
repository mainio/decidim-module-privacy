# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Debates", type: :system do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when trying to create a new debate" do
    let!(:component) { create(:debates_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component

      expect(page).to have_content("New debate")
      click_link "New debate"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
      )

      find("#publish_account_agree_public_profile").check

      click_button "Make your profile public"

      expect(page).to have_content("NEW DEBATE")
      expect(page).to have_content("Title")
      expect(page).to have_content("Description")
    end

    context "when trying to visit url for creating a new debate" do
      it "renders a custom page with a prompt which has to be accepted in order to proceed" do
        visit new_debate_path(component)

        expect(page).to have_content("Public profile is required for this action")
        expect(page).to have_content("You are trying to access a page which requires your profile to be public. Making your profile public allows other participants to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

        click_button "Publish your profile"

        find("#publish_account_agree_public_profile").check

        click_button "Make your profile public"

        expect(page).to have_content("NEW DEBATE")
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
      end
    end
  end

  context "when user has created a debate" do
    let!(:component) { create(:debates_component, :with_creation_enabled, participatory_space: participatory_process) }
    let!(:debate) { create(:debate, author: user, component: component) }

    it "shows author name when user public" do
      user.update(published_at: Time.current)
      visit_component

      within ".card--debate", match: :first do
        expect(page).to have_content(user.name)
      end

      within ".author-data" do
        expect(page).to have_selector("a[href='/profiles/#{user.nickname}']")
      end
    end

    it "hides author name when user private" do
      visit_component

      within ".card--debate", match: :first do
        expect(page).not_to have_content(user.name)
      end

      expect(page).not_to have_selector(".author-data")
    end

    context "when user tries to edit debate" do
      context "when user private" do
        it "doesn't render edit button" do
          visit_component
          click_link debate.title["en"]

          expect(page).not_to have_link("Edit")
        end
      end
    end
  end

  def new_debate_path(component)
    Decidim::EngineRouter.main_proxy(component).new_debate_path(component.id)
  end
end

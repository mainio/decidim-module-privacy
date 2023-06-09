# frozen_string_literal: true

require "spec_helper"

describe "User privacy", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, :with_steps, organization: organization }
  let(:manifest_name) { "proposals" }
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }
  let!(:component) { create(:proposal_component, :with_creation_enabled, manifest: manifest, participatory_space: participatory_process) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  def visit_component
    switch_to_host(organization.host)
    page.visit main_component_path(component)
  end

  before do
    login_as user, scope: :user
    visit_component
  end

  context "when user private" do
    context "when trying to create a new proposal" do
      it "gives you a popup for consent" do
        expect(page).to have_content("New proposal")
        click_link "New proposal"

        expect(page).to have_content("Make your profile public")
        expect(page).to have_content(
          "In order to perform any public actions on this platform, you need to make your profile public. This means that a public profile about you will be provided on this platform where other people can see the following information about you:"
        )
      end
    end

    context "when trying to visit url for creating a new proposal" do
      it "renders a custom page with a message" do
        visit new_proposal_path(component)

        expect(page).to have_content("Publication of account needed")
        expect(page).to have_content("You are trying to access a page which requires your account to be public. Making your profile public allows other users to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")
      end
    end

    context "when opening user menu" do
      it "doesn't have 'My public profile' link" do
        click_link user.name
        expect(page).not_to have_link("My public profile")
      end
    end
  end

  context "when user public" do
    context "when accepting publishing of profile" do
      it "redirects you to the desired page" do
        user.update(published_at: "2023-06-06 10:08:20.796179000 +0000")

        visit new_proposal_path(component)

        expect(page).to have_content("You are creating a proposal.")
        expect(page).to have_content("CREATE YOUR PROPOSAL")
        expect(page).to have_content("Continue")
      end
    end

    context "when opening user menu" do
      it "has 'My public profile' link" do
        user.update(published_at: "2023-06-06 10:08:20.796179000 +0000")

        visit current_path
        click_link user.name
        expect(page).to have_link("My public profile")
      end
    end
  end

  def new_proposal_path(component)
    Decidim::EngineRouter.main_proxy(component).new_proposal_path(component.id)
  end
end

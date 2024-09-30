# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Proposals" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:proposal) { create(:proposal, :official, :published, component:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  context "when trying to edit an official proposal" do
    let!(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "lets the admin user to edit" do
      click_on "Processes"
      click_on participatory_process.title["en"]
      click_on "Proposals"
      expect(page).to have_content(proposal.title["en"])
      within("a.action-icon--edit-proposal") do
        expect(page).to have_css('svg[aria-label="Edit proposal"]')
      end
    end
  end
end

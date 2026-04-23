# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "ProposalNote" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:proposal) { create(:proposal, :published, component:) }
  let!(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  context "when user makes a proposal note" do
    context "when user public" do
      let!(:user) { create(:user, :published, :admin, :confirmed, organization:) }

      it "shows the note and author of it correctly" do
        click_on "Processes"
        click_on participatory_process.title["en"]
        click_on "Proposals"
        expect(page).to have_content(proposal.title["en"])
        within ".table-list" do
          within ".table-list__actions" do
            click_on "Answer proposal"
          end
        end
        expect(page).to have_content(proposal.title["en"])
        within ".component__show_notes" do
          find(".card-divider-button").click
        end

        fill_in "proposal_note[body]", with: "Test"

        within ".new_proposal_note" do
          click_on "Submit"
        end

        within ".component__show_notes" do
          find(".card-divider-button").click

          expect(page).to have_content(user.name)
          expect(page).to have_content("Test")
        end
      end
    end

    context "when user private" do
      let!(:user) { create(:user, :admin, :confirmed, organization:) }

      it "shows the note and author of it correctly" do
        click_on "Processes"
        click_on participatory_process.title["en"]
        click_on "Proposals"
        expect(page).to have_content(proposal.title["en"])
        within ".table-list" do
          within ".table-list__actions" do
            click_on "Answer proposal"
          end
        end
        expect(page).to have_content(proposal.title["en"])
        within ".component__show_notes" do
          find(".card-divider-button").click
        end

        fill_in "proposal_note[body]", with: "Test"

        within ".new_proposal_note" do
          click_on "Submit"
        end

        within ".component__show_notes" do
          find(".card-divider-button").click

          expect(page).to have_content(user.name)
          expect(page).to have_content("Test")
        end
      end
    end

    context "when user anonymous", :anonymity do
      let!(:user) { create(:user, :anonymous, :admin, :confirmed, organization:) }

      it "shows the note and author of it correctly" do
        click_on "Processes"
        click_on participatory_process.title["en"]
        click_on "Proposals"
        expect(page).to have_content(proposal.title["en"])
        within ".table-list" do
          within ".table-list__actions" do
            click_on "Answer proposal"
          end
        end
        expect(page).to have_content(proposal.title["en"])
        within ".component__show_notes" do
          find(".card-divider-button").click
        end

        fill_in "proposal_note[body]", with: "Test"

        within ".new_proposal_note" do
          click_on "Submit"
        end

        within ".component__show_notes" do
          find(".card-divider-button").click

          expect(page).to have_content(user.name)
          expect(page).to have_content("Test")
        end
      end
    end
  end
end

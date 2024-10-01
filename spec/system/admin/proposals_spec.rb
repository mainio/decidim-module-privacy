# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:proposal) { create :proposal, :official, component: component }

  include_context "when managing a component as an admin"

  describe "editing an official proposal" do
    it "can be updated" do
      visit_component_admin

      find("a.action-icon--edit-proposal").click
      expect(page).to have_content "Update proposal"
    end
  end
end

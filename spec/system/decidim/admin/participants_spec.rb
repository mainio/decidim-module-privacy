# frozen_string_literal: true

require "spec_helper"
describe "Admin blocks private user", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:visitor) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    click_on "Participants"
    within ".secondary-nav" do
      click_on "Participants"
    end
  end

  context "when private user blocked" do
    it "finds the user and blocks them" do
      find("a[title='Block User']").click
      expect(page).to have_content("Block User #{visitor.name}")

      fill_in "block_user_justification", with: "Example of a justification"
      click_on "Block account and send justification"

      expect(page).to have_content("Participant successfully blocked")
    end
  end

  context "when anonymous user blocked", :anonymity do
    let!(:visitor) { create(:user, :anonymous, :confirmed, organization: organization) }

    it "finds the user and blocks them" do
      find("a[title='Block User']").click
      expect(page).to have_content("Block User #{visitor.name}")

      fill_in "block_user_justification", with: "Example of a justification"
      click_on "Block account and send justification"

      expect(page).to have_content("Participant successfully blocked")
    end
  end
end

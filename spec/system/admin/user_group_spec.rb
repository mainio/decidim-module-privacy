# frozen_string_literal: true

require "spec_helper"

describe "UserGroups" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:pending_ug) { create(:user_group, organization:, users: [user]) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.user_groups_path
  end

  context "when user group is not confirmed" do
    it "gives a flash alert that the user group needs to be confirmed before verification" do
      within "td.table-list__actions" do
        click_on "Verify"
      end
      expect(page).to have_content("The group's email address has to be confirmed in order to verify the group.")
    end
  end
end

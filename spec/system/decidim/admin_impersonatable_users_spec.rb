# frozen_string_literal: true

require "spec_helper"

describe "AdminImpersonatableUsers" do
  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_on "Participants"
  end

  describe "listing impersonatable users" do
    let!(:managed) { create(:user, :managed, organization:) }
    let!(:not_managed) { create(:user, organization:) }

    let!(:deleted) { create(:user, :confirmed, :deleted, organization:) }
    let!(:external_not_managed) { create(:user) }
    let!(:another_admin) { create(:user, :admin) }
    let!(:user_manager) { create(:user, :user_manager) }

    before do
      click_on "Impersonations"
    end

    it "shows each user and its managed status" do
      expect(page).to have_css("tr[data-user-id=\"#{managed.id}\"]", text: managed.name)
      expect(page).to have_css("tr[data-user-id=\"#{managed.id}\"]", text: "Managed")

      expect(page).to have_css("tr[data-user-id=\"#{not_managed.id}\"]", text: not_managed.name)
      expect(page).to have_css("tr[data-user-id=\"#{not_managed.id}\"]", text: "Not managed")

      expect(page).to have_no_selector("tr[data-user-id=\"#{deleted.id}\"]", text: deleted.name)
      expect(page).to have_no_selector("tr[data-user-id=\"#{external_not_managed.id}\"]", text: external_not_managed.name)
      expect(page).to have_no_selector("tr[data-user-id=\"#{another_admin.id}\"]", text: another_admin.name)
      expect(page).to have_no_selector("tr[data-user-id=\"#{user_manager.id}\"]", text: user_manager.name)
    end
  end
end

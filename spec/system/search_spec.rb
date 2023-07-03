# frozen_string_literal: true

require "spec_helper"

describe "User privacy", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

  before do
    login_as user, scope: :user
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when user private" do
    it "doesn't show up in search" do
      fill_in "term", with: user.name
      find("button[name='commit']").click

      expect(page).to have_content("0 RESULTS FOR THE SEARCH: \"#{user.name.upcase}")
    end

    it "shows up in the admin search" do
      login_as admin, scope: :user
      visit decidim.root_path

      click_link "user-menu-control"
      click_link "Admin dashboard"
      click_link "Participants"

      click_link "Participants"
      expect(page).to have_content(user.name)
    end
  end

  context "when user public" do
    it "shows up in search" do
      user.update(published_at: Time.current)

      fill_in "term", with: user.name
      find("button[name='commit']").click

      expect(page).to have_content("1 RESULTS FOR THE SEARCH: \"#{user.name.upcase}")
      expect(page).to have_selector("a", text: user.name)
    end
  end

  context "when user group is not verified" do
    let!(:user_group) { create(:user_group, :confirmed, organization: organization, users: [admin]) }

    it "doesn't show up in search" do
      fill_in "term", with: user_group.name
      find("button[name='commit']").click

      expect(page).to have_content("0 RESULTS FOR THE SEARCH: \"#{user_group.name.upcase}")
    end

    it "shows up in the admin search" do
      login_as admin, scope: :user
      visit decidim.root_path

      click_link "user-menu-control"
      click_link "Admin dashboard"
      click_link "Participants"
      click_link "Groups"

      expect(page).to have_content(user_group.name)
    end
  end

  context "when user group is verified" do
    let!(:user_group) { create(:user_group, :confirmed, :verified, organization: organization) }

    it "shows up in search" do
      fill_in "term", with: user_group.name
      find("button[name='commit']").click

      expect(page).to have_content("1 RESULTS FOR THE SEARCH: \"#{user_group.name.upcase}")
      expect(page).to have_selector("a", text: user_group.name)
    end
  end

  def visit_component
    page.visit main_component_path(component)
  end
end

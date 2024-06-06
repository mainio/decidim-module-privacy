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
    expect(page).to have_content(organization.name)

    # Ensure there is no "on_next_request" block stored at Warden before running
    # the test in case we want to login some other user.
    Warden.test_reset!
  end

  context "when listing users" do
    context "when user private" do
      it "does not show up in search" do
        fill_in "term", with: user.name
        find("button[type='submit'][aria-label='Search']").click

        expect(page).to have_content("0 Results for the search: \"#{user.name}")
      end

      it "shows up in the admin search" do
        login_as admin, scope: :user
        visit decidim.root_path

        click_on "Admin dashboard"
        click_on "Participants"
        within ".sidebar-menu" do
          click_on "Participants"
        end

        expect(page).to have_content(user.name)
      end
    end

    context "when user public" do
      it "shows up in search" do
        user.update(published_at: Time.current)

        fill_in "term", with: user.name
        find("button[type='submit'][aria-label='Search']").click

        expect(page).to have_content("1 Results for the search: \"#{user.name}")
        expect(page).to have_css("a", text: user.name)
      end
    end
  end

  context "when listing user groups" do
    context "when user group is not verified but is confirmed" do
      let!(:user_group) { create(:user_group, :confirmed, organization:, users: [admin]) }

      it "does not show up in search" do
        fill_in "term", with: user_group.name
        find("button[type='submit'][aria-label='Search']").click

        expect(page).to have_content("0 Results for the search: \"#{user_group.name}")
      end

      it "shows up in the admin search" do
        login_as admin, scope: :user
        visit decidim.root_path

        click_on "Admin dashboard"
        click_on "Participants"
        click_on "Groups"

        expect(page).to have_content(user_group.name)
      end
    end

    context "when user group is verified and confirmed" do
      let!(:user_group) { create(:user_group, :confirmed, :verified, organization:) }

      it "shows up in search" do
        fill_in "term", with: user_group.name
        find("button[type='submit'][aria-label='Search']").click

        expect(page).to have_content("1 Results for the search: \"#{user_group.name}")
        expect(page).to have_css("a", text: user_group.name)
      end
    end

    context "when user group is not confirmed" do
      let!(:user_group) { create(:user_group, organization:, users: [admin]) }

      it "does not show up in search" do
        fill_in "term", with: user_group.name
        find("button[type='submit'][aria-label='Search']").click

        expect(page).to have_content("0 Results for the search: \"#{user_group.name}")
      end

      it "shows up in the admin search" do
        login_as admin, scope: :user
        visit decidim.root_path

        click_on "Admin dashboard"
        click_on "Participants"
        click_on "Groups"

        expect(page).to have_content(user_group.name)
      end
    end
  end

  def visit_component
    page.visit main_component_path(component)
  end
end

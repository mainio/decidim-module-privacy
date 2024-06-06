# frozen_string_literal: true

require "spec_helper"

describe "User group" do
  let!(:organization) { create(:organization) }
  let!(:user_group) { create(:user_group, :verified, :confirmed, organization:, users: group_users) }
  let(:group_users) { [public_member, private_member] }

  let(:public_member) { create(:user, :confirmed, :published, organization:) }
  let(:private_member) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as public_member, scope: :user
    visit decidim.profile_members_path(nickname: user_group.nickname)
  end

  it "displays only public members" do
    expect(page).to have_content(public_member.name)
    expect(page).to have_no_content(private_member.name)
  end

  context "with private user" do
    let(:private_user) { create(:user, :confirmed, organization:) }

    before do
      expect(page).to have_content(user_group.name)
      login_as private_user, scope: :user
      visit current_path
    end

    it "does not display the join group button" do
      expect(page).to have_no_link("Request to join group")
    end
  end

  context "with public user" do
    let(:public_user) { create(:user, :confirmed, :published, organization:) }

    before do
      expect(page).to have_content(user_group.name)
      login_as public_user, scope: :user
      visit current_path
    end

    it "displays the join group button" do
      expect(page).to have_link("Request to join group")
    end
  end

  context "when managing members" do
    let!(:private_pending_request) { create(:user_group_membership, user: private_requester, user_group:, role: "requested") }
    let!(:public_pending_request) { create(:user_group_membership, user: public_requester, user_group:, role: "requested") }
    let(:private_requester) { create(:user, :confirmed, organization:) }
    let(:public_requester) { create(:user, :confirmed, :published, organization:) }

    before do
      expect(page).to have_content(user_group.name)
      find_by_id("trigger-dropdown-user-group").click
      within ".profile__actions-main__dropdown" do
        find("a[title='Manage members']").click
      end
    end

    it "displays the requests only for public users" do
      within "#list-request" do
        expect(page).to have_link("Accept", count: 1)
        expect(page).to have_content(public_requester.name)
        expect(page).to have_no_content(private_requester.name)
      end
    end
  end
end

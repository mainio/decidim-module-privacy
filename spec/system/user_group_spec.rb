# frozen_string_literal: true

require "spec_helper"

describe "User group", type: :system do
  let!(:organization) { create(:organization) }
  let!(:user_group) { create(:user_group, :verified, :confirmed, organization: organization, users: group_users) }
  let(:group_users) { [public_member, private_member] }

  let(:public_member) { create(:user, :confirmed, :published, organization: organization) }
  let(:private_member) { create(:user, :confirmed, organization: organization) }

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
    let(:private_user) { create(:user, :confirmed, organization: organization) }

    before do
      expect(page).to have_content(user_group.name)
      login_as private_user, scope: :user
      visit current_path
    end

    it "does not display the join group button" do
      expect(page).not_to have_link("Request to join group")
    end
  end

  context "with public user" do
    let(:public_user) { create(:user, :confirmed, :published, organization: organization) }

    before do
      expect(page).to have_content(user_group.name)
      login_as public_user, scope: :user
      visit current_path
    end

    it "displays the join group button" do
      expect(page).to have_link("Request to join group")
    end
  end
end

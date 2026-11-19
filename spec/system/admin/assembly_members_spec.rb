# frozen_string_literal: true

require "spec_helper"

describe "AssemblyMembers" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:other_user) { create(:user, organization:, email: "my_email@example.org") }
  let!(:assembly_private_user) { create(:member, user: other_user, participatory_space: assembly) }
  let(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, :restricted, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_on "Members"
    end
  end

  context "when assembly member private" do
    it "shows assembly user list" do
      within "#members table" do
        expect(page).to have_content(other_user.name)
        expect(page).to have_content(other_user.email)
      end
    end
  end

  context "when assembly member public" do
    let(:other_user) { create(:user, :published, organization:, email: "my_email@example.org") }

    it "shows assembly user list" do
      within "#members table" do
        expect(page).to have_content(other_user.name)
        expect(page).to have_content(other_user.email)
      end
    end
  end

  context "when assembly member anonymous", :anonymity do
    let(:other_user) { create(:user, :anonymous, organization:, email: "my_email@example.org") }

    it "shows assembly user list" do
      within "#members table" do
        expect(page).to have_content(other_user.name)
        expect(page).to have_content(other_user.email)
      end
    end
  end
end

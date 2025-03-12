# frozen_string_literal: true

require "spec_helper"

describe "Assemblies", type: :system do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when listing assembly members" do
    let!(:assembly) { create(:assembly, organization: organization) }

    context "when assembly has no members" do
      let!(:user) { create(:user, :confirmed, organization: organization) }

      it "has no 'members' tab" do
        visit_assembly

        expect(page).not_to have_link("Members")
      end
    end

    context "when member private" do
      let(:user) { create(:user, :confirmed, organization: organization) }
      let!(:assembly_member) { create(:assembly_member, assembly: assembly, user: user) }

      it "shows empty list" do
        visit_assembly
        click_link "Members"

        expect(page).to have_content("MEMBERS (0)")
      end
    end

    context "when member anonymous", :anonymity do
      let(:user) { create(:user, :anonymous, :confirmed, organization: organization) }
      let!(:assembly_member) { create(:assembly_member, assembly: assembly, user: user) }

      it "shows empty list" do
        visit_assembly
        click_link "Members"

        expect(page).to have_content("MEMBERS (0)")
      end
    end

    context "when member public" do
      let(:user) { create(:user, :confirmed, :published, organization: organization) }
      let!(:assembly_member) { create(:assembly_member, assembly: assembly, user: user) }

      it "shows list with one user" do
        visit_assembly
        click_link "Members"

        expect(page).to have_content("MEMBERS (1)")
        expect(page).to have_content(user.name)
      end
    end

    context "when one member public, one member private and one member anonymous" do
      let(:public_member) { create(:user, :confirmed, :published, organization: organization) }
      let(:private_member) { create(:user, :confirmed, organization: organization) }
      let(:anonymous_member) { create(:user, :anonymous, :confirmed, organization: organization) }
      let!(:public_assembly_member) { create(:assembly_member, assembly: assembly, user: public_member) }
      let!(:private_assembly_member) { create(:assembly_member, assembly: assembly, user: private_member) }
      let!(:anonymous_assembly_member) { create(:assembly_member, assembly: assembly, user: anonymous_member) }

      it "shows list with one user" do
        visit_assembly
        click_link "Members"

        expect(page).to have_content("MEMBERS (1)")
        expect(page).to have_content(public_member.name)
        expect(page).not_to have_content(private_member.name)
      end
    end

    context "when listing user group members" do
      context "when user group has no members" do
        let(:user_group) { create(:user_group, :confirmed, :verified, published_at: Time.current, organization: organization) }

        it "shows no members" do
          visit decidim.profile_path(user_group.nickname)

          expect(page).to have_content("This group does not have any members.")
        end
      end

      context "when user group has private members" do
        let!(:user) { create(:user, :confirmed, organization: organization) }
        let(:user_group) { create(:user_group, :confirmed, :verified, users: [user], published_at: Time.current, organization: organization) }

        it "shows no members" do
          visit decidim.profile_path(user_group.nickname)

          within "#content" do
            expect(page).to have_content("This group does not have any public members.")
            expect(page).not_to have_content(user.name)
          end
        end
      end

      context "when user group has anonymous members" do
        let!(:user) { create(:user, :anonymous, :confirmed, organization: organization) }
        let(:user_group) { create(:user_group, :confirmed, :verified, users: [user], published_at: Time.current, organization: organization) }

        it "shows no members" do
          visit decidim.profile_path(user_group.nickname)

          within "#content" do
            expect(page).to have_content("This group does not have any public members.")
            expect(page).not_to have_content(user.name)
          end
        end
      end

      context "when user group has public members" do
        let(:user_group) { create(:user_group, :confirmed, :verified, users: [user], published_at: Time.current, organization: organization) }
        let!(:user) { create(:user, :confirmed, :published, organization: organization) }

        it "shows public members" do
          visit decidim.profile_path(user_group.nickname)

          within "#content" do
            expect(page).to have_content(user.name)
          end
        end
      end
    end
  end

  def visit_assembly
    visit decidim_assemblies.assembly_path(assembly)
  end
end

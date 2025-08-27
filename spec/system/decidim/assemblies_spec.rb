# frozen_string_literal: true

require "spec_helper"

describe "Assemblies" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when listing assembly members" do
    let(:show_statistics) { true }

    let(:description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
    let(:short_description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
    let(:purpose_of_action) { { en: "Purpose of action", ca: "Propòsit de l'acció", es: "Propósito de la acción" } }
    let(:internal_organisation) { { en: "Internal organisation", ca: "Organització interna", es: "Organización interna" } }
    let(:composition) { { en: "Composition", ca: "Composició", es: "Composición" } }
    let(:closing_date_reason) { { en: "Closing date reason", ca: "Motiu de la data de tancament", es: "Razón de la fecha de cierre" } }
    let(:blocks_manifests) { ["main_data"] }

    let(:assembly) do
      create(
        :assembly,
        :with_type,
        :with_content_blocks,
        :published,
        organization:,
        description:,
        short_description:,
        purpose_of_action:,
        internal_organisation:,
        composition:,
        closing_date_reason:,
        show_statistics:,
        blocks_manifests:
      )
    end

    context "when assembly has no members" do
      let!(:user) { create(:user, :confirmed, organization:) }

      it "has no 'members' tab" do
        visit_assembly

        expect(page).to have_no_link("Members")
      end
    end

    context "when member private" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:assembly_member) { create(:assembly_member, assembly:, user:) }

      it "shows empty list" do
        visit_assembly
        click_on "Members"

        within ".decorator" do
          expect(page).to have_content("Members")
          expect(page).to have_css("span", text: "0")
        end
      end
    end

    context "when member anonymous", :anonymity do
      let(:user) { create(:user, :anonymous, :confirmed, organization:) }
      let!(:assembly_member) { create(:assembly_member, assembly:, user:) }

      it "shows empty list" do
        visit_assembly
        click_on "Members"

        within ".decorator" do
          expect(page).to have_content("Members")
          expect(page).to have_css("span", text: "0")
        end
      end
    end

    context "when member public" do
      let!(:user) { create(:user, :confirmed, :published, organization:) }
      let!(:assembly_member) { create(:assembly_member, assembly:, user:) }

      it "shows list with one user" do
        visit_assembly
        click_on "Members"

        within ".decorator" do
          expect(page).to have_content("Members")
          expect(page).to have_css("span", text: "1")
        end
      end
    end

    context "when one member public, one member private and one member anonymous" do
      let!(:public_member) { create(:user, :confirmed, :published, organization:) }
      let!(:private_member) { create(:user, :confirmed, organization:) }
      let!(:anonymous_member) { create(:user, :anonymous, :confirmed, organization:) }
      let!(:public_assembly_member) { create(:assembly_member, assembly:, user: public_member) }
      let!(:private_assembly_member) { create(:assembly_member, assembly:, user: private_member) }
      let!(:anonymous_assembly_member) { create(:assembly_member, assembly:, user: anonymous_member) }

      it "shows list with one user" do
        visit_assembly
        expect(page).to have_content("Members")
        click_on "Members"

        within ".decorator" do
          expect(page).to have_content("Members")
          expect(page).to have_css("span", text: "1")
        end
        expect(page).to have_content(public_member.name)
        expect(page).to have_no_content(private_member.name)
      end
    end

    context "when listing user group members" do
      context "when user group has no members" do
        let(:user_group) { create(:user_group, :confirmed, :verified, published_at: Time.current, organization:) }

        it "shows no members" do
          visit decidim.profile_path(user_group.nickname)

          expect(page).to have_content("This group does not have any members.")
        end
      end

      context "when user group has private members" do
        let!(:user) { create(:user, :confirmed, organization:) }
        let(:user_group) { create(:user_group, :confirmed, :verified, users: [user], published_at: Time.current, organization:) }

        it "shows no members" do
          visit decidim.profile_path(user_group.nickname)

          within "#content" do
            expect(page).to have_content("This group does not have any public members.")
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when user group has anonymous members" do
        let!(:user) { create(:user, :anonymous, :confirmed, organization:) }
        let(:user_group) { create(:user_group, :confirmed, :verified, users: [user], published_at: Time.current, organization:) }

        it "shows no members" do
          visit decidim.profile_path(user_group.nickname)

          within "#content" do
            expect(page).to have_content("This group does not have any public members.")
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when user group has public members" do
        let(:user_group) { create(:user_group, :confirmed, :verified, users: [user], published_at: Time.current, organization:) }
        let!(:user) { create(:user, :confirmed, :published, organization:) }

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

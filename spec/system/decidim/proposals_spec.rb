# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Proposals" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:visitor) { create(:user, :confirmed, :published, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when trying to create a new proposal" do
    let!(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component

      expect(page).to have_content("New proposal")
      click_on "New proposal"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
      )

      find_by_id("publish_account_agree_public_profile").check

      click_on "Make your profile public"
      expect(page).to have_no_content("Make your profile public")
      expect(Decidim::User.entire_collection.first.public?).to be(true)
      expect(page).to have_content("Create your proposal")
      expect(page).to have_content("Title")
      expect(page).to have_content("Body")
    end

    context "when trying to visit url for creating a new proposal" do
      it "renders a custom page with a prompt which has to be accepted in order to proceed" do
        visit new_proposal_path(component)

        expect(page).to have_content("PUBLIC PROFILE IS REQUIRED FOR THIS ACTION")
        expect(page).to have_content("You are trying to access a page which requires your profile to be public. Making your profile public allows other participants to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

        click_on "Publish your profile"

        find_by_id("publish_account_agree_public_profile").check

        click_on "Make your profile public"

        expect(page).to have_content("Create your proposal")
        expect(page).to have_content("Title")
        expect(page).to have_content("Body")
      end
    end
  end

  context "when user has created a proposal" do
    let!(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, component:, users: [user]) }

    it "shows author name when user public" do
      user.update(published_at: Time.current)
      visit_component

      within "a.card__list", match: :first do
        expect(page).to have_content(user.name)
      end
    end

    it "hides author name when user private" do
      visit_component

      within ".card__list", match: :first do
        expect(page).to have_no_content(user.name)
        expect(page).to have_content("Private participant")
      end
    end

    context "when user tries to edit proposal" do
      context "when user private" do
        it "doesn't render edit button" do
          visit_component
          click_on proposal.title["en"]

          expect(page).to have_no_link("Edit proposal")
        end
      end
    end
  end

  context "when user leaves an endorsement" do
    let!(:component) { create(:proposal_component, :with_creation_enabled, :with_endorsements_enabled, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, component:, users: [user]) }

    it "shows user's name in endorsements list if public" do
      user.update(published_at: Time.current)
      visit_component

      click_on proposal.title["en"]
      click_on "Like"
      refresh

      expect(page).to have_css(".endorsers-list__trigger")

      find(".endorsers-list__trigger").click

      within ".endorsers-list__grid" do
        expect(page).to have_css("a[href='/profiles/#{user.nickname}']")
      end
    end

    it "hides user's name in endorsements list if private" do
      user.update(published_at: Time.current)
      visit_component

      click_on proposal.title["en"]
      click_on "Like"
      refresh

      expect(page).to have_css(".endorsers-list__trigger")
      user.update(published_at: nil)
      user.reload

      login_as visitor, scope: :user
      visit_component
      click_on proposal.title["en"]

      find(".endorsers-list__trigger").click

      within ".endorsers-list__grid" do
        expect(page).to have_no_css("a[href='/profiles/#{user.nickname}']")
      end
    end

    it "hides endorsement if user private" do
      visit_component

      click_on proposal.title["en"]
      expect(page).to have_no_button("Endorse")
    end
  end

  context "when creating a coauthored proposal" do
    let!(:component) { create(:proposal_component, :with_creation_enabled, :with_endorsements_enabled, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, component:, users: [user, coauthor], skip_injection: true) }
    let!(:coauthor) { create(:user, :confirmed, :published, organization:) }

    it "shows authors correctly if both users public" do
      user.update(published_at: Time.current)
      visit_component

      within ".card__list" do
        expect(page).to have_css("img[alt='Avatar: #{coauthor.name}']")
        expect(page).to have_css("img[alt='Avatar: #{user.name}']")
      end
    end

    it "shows authors correctly if one user private" do
      visit_component

      within ".card__list" do
        expect(page).to have_css("img[alt='Avatar: Private participant']")
        expect(page).to have_css("img[alt='Avatar: #{coauthor.name}']")
      end
    end
  end

  context "when requesting access to a collaborative draft" do
    let!(:scope) { create(:scope, organization:) }
    let!(:author) { create(:user, :confirmed, :published, organization:) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             participatory_space: participatory_process,
             organization:,
             settings: {
               collaborative_drafts_enabled: true,
               scopes_enabled: true,
               scope_id: participatory_process.scope&.id
             })
    end

    let!(:collaborative_draft) { create(:collaborative_draft, :open, component:, scope:, users: [author]) }

    before do
      sign_in user, scope: :user
      visit main_component_path(component)
      click_on "Access collaborative drafts"
    end

    context "when private user" do
      it "hides the button to request access" do
        expect(page).to have_content(collaborative_draft.title)
        click_on collaborative_draft.title
        within ".layout-item__aside" do
          expect(page).to have_content("Version number")
          expect(page).to have_no_button("Request access")
        end
      end
    end

    context "when public user" do
      it "renders a button to request access" do
        user.update(published_at: Time.current)
        expect(page).to have_content(translated(collaborative_draft.title))
        click_on translated(collaborative_draft.title)
        within ".layout-item__aside" do
          expect(page).to have_content("Version number")
          expect(page).to have_button("Request access")
        end
      end
    end

    context "when user tries to edit collaborative draft" do
      context "when user private" do
        it "doesn't render the edit button" do
          author.update(published_at: nil)
          sign_in author, scope: :user
          click_on translated(collaborative_draft.title)

          expect(page).to have_no_link("Edit collaborative draft")
        end
      end
    end
  end

  def new_proposal_path(component)
    Decidim::EngineRouter.main_proxy(component).new_proposal_path(component.id)
  end
end

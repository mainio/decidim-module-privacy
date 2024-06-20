# frozen_string_literal: true

require "spec_helper"

describe "Initiatives" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when trying to create a new initiative" do
    let!(:initiative) { create(:initiative, :created, author: user, organization:) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:authorization) { create(:authorization, :granted, user:) }
    let!(:initiatives_type) { create(:initiatives_type, organization:) }

    context "when user private" do
      it "renders a site that tells user to publish your account" do
        visit decidim_initiatives.initiatives_path
        click_on "New initiative"

        within ".initiatives__selection" do
          click_on(initiative.title["es"])
        end

        expect(page).to have_content("You are trying to access a page which requires your profile to be public.")
      end
    end

    context "when user public" do
      let!(:user) { create(:user, :confirmed, :published, organization:) }

      it "renders the site to create a new initiative" do
        visit decidim_initiatives.initiatives_path
        click_on "New initiative"

        expect(page).to have_content(
          "Initiatives are a means by which the participants can intervene so that the organization can undertake actions in defence of the general interest. Which initiative do you want to launch?"
        )
        expect(page).to have_content(initiatives_type.title["es"].to_s)
      end
    end

    context "when user tries to edit initiative" do
      context "when user private" do
        it "renders a site that tells user to publish your account" do
          visit decidim_initiatives.initiatives_path

          find("label", text: "My initiatives").click
          uncheck("Open")
          click_on initiative.title["en"]
          click_on "Edit"

          expect(page).to have_content("You are trying to access a page which requires your profile to be public.")
        end
      end

      context "when user public" do
        let!(:user) { create(:user, :confirmed, :published, organization:) }

        it "renders the site to edit initiative" do
          visit decidim_initiatives.initiatives_path

          find("label", text: "My initiatives").click
          uncheck("Open")
          click_on initiative.title["en"]
          click_on "Edit"

          expect(page).to have_content("Edit Initiative")
        end
      end
    end
  end
end

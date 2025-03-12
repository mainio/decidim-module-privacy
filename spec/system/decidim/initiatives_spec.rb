# frozen_string_literal: true

require "spec_helper"

describe "Initiatives", type: :system do
  let!(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, :created, author: user, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) { create(:authorization, :granted, user: user) }
  let!(:initiatives_type) { create(:initiatives_type, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when anonymity disabled" do
    context "when trying to create a new initiative" do
      context "when user private" do
        it "renders a site that tells user to publish your account" do
          visit decidim_initiatives.initiatives_path
          click_link "New initiative"
          expect(page).to have_content("You are trying to access a page which requires your profile to be public.")
        end
      end

      context "when user public" do
        let!(:user) { create(:user, :confirmed, :published, organization: organization) }

        it "renders the site to create a new initiative" do
          visit decidim_initiatives.initiatives_path
          click_link "New initiative"

          expect(page).to have_content("I want to create a #{initiatives_type.title["es"]}")
          expect(page).to have_content("I want to promote this initiative")
        end
      end

      context "when user tries to edit initiative" do
        context "when user private" do
          it "renders a site that tells user to publish your account" do
            visit decidim_initiatives.initiatives_path

            find("label", text: "My initiatives").click
            uncheck("Open")
            click_link initiative.title["en"]
            click_link "Edit"

            expect(page).to have_content("You are trying to access a page which requires your profile to be public.")
          end
        end

        context "when user public" do
          let!(:user) { create(:user, :confirmed, :published, organization: organization) }

          it "renders the site to edit initiative" do
            visit decidim_initiatives.initiatives_path

            find("label", text: "My initiatives").click
            uncheck("Open")
            click_link initiative.title["en"]
            click_link "Edit"

            expect(page).to have_content("EDIT INITIATIVE")
          end
        end
      end

      context "when initiative is done by private user" do
        let!(:initiative) { create(:initiative, author: user, organization: organization) }

        it "doesn't show author name" do
          visit decidim_initiatives.initiatives_path

          within ".card--initiative", match: :first do
            expect(page).not_to have_content(user.name)
            expect(page).to have_content("Unnamed participant")
          end
        end
      end
    end
  end

  context "when anonymity enabled", :anonymity do
    let!(:user) { create(:user, :confirmed, organization: organization) }

    context "when trying to create a new initiative" do
      context "when user anonymous" do
        it "renders a site that tells user to publish your account" do
          visit decidim_initiatives.initiatives_path
          click_link "New initiative"
          expect(page).to have_content("Your profile is anonymous")
        end
      end

      context "when user tries to edit initiative" do
        context "when user set as anonymous" do
          let!(:user) { create(:user, :anonymous, :confirmed, organization: organization) }

          it "renders the site to edit initiative" do
            visit decidim_initiatives.initiatives_path

            find("label", text: "My initiatives").click
            uncheck("Open")
            click_link initiative.title["en"]
            click_link "Edit"

            expect(page).to have_content("EDIT INITIATIVE")
          end
        end
      end

      context "when initiative is done by anonymous user" do
        let!(:initiative) { create(:initiative, author: user, organization: organization) }

        it "doesn't show author name" do
          visit decidim_initiatives.initiatives_path

          within ".card--initiative", match: :first do
            expect(page).not_to have_content(user.name)
            expect(page).to have_content("Unnamed participant")
          end
        end
      end
    end
  end
end

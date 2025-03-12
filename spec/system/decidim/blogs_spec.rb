# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Blogs", type: :system do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when visiting a blog post" do
    let!(:component) { create(:post_component, participatory_space: participatory_process) }
    let!(:post) { create(:post, component: component) }

    context "when user public" do
      let!(:user) { create(:user, :confirmed, :published, organization: organization) }

      it "shows endorse, follow and comments -buttons" do
        user.update(published_at: Time.current)
        visit_blog_post

        within ".view-side" do
          expect(page).to have_button("Endorse")
          expect(page).to have_selector('[href="#comments"]')
          expect(page).to have_selector(".follow-button")
        end
      end
    end

    context "when user anonymous" do
      let!(:user) { create(:user, :anonymous, :confirmed, :published, organization: organization) }

      it "shows endorse, follow and comments -buttons" do
        visit_blog_post

        within ".view-side" do
          expect(page).to have_button("Endorse")
          expect(page).to have_selector('[href="#comments"]')
          expect(page).to have_selector(".follow-button")
        end
      end
    end

    context "when user private" do
      it "hides endorse button" do
        visit_blog_post

        within ".view-side" do
          expect(page).to have_selector('[href="#comments"]')
          expect(page).to have_selector(".follow-button")
        end
      end
    end

    context "when no signed in user" do
      it "hides endorse button" do
        visit_blog_post

        within_user_menu do
          find(".sign-out-link").click
        end

        expect(page).not_to have_selector(".view-side")
      end
    end
  end

  def visit_blog_post
    visit_component
    click_link post.title["en"]
  end
end

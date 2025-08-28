# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Blogs" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when visiting a blog post" do
    let!(:component) { create(:post_component, participatory_space: participatory_process) }
    let!(:post) { create(:post, component:) }

    context "when user public" do
      let!(:user) { create(:user, :confirmed, :published, organization:) }

      it "shows endorse, follow and comments -buttons" do
        user.update(published_at: Time.current)
        visit_blog_post

        within ".blog__actions" do
          expect(page).to have_link("Follow")
          expect(page).to have_button("Like")
          expect(page).to have_link("Comment")
        end
      end
    end

    context "when user anonymous" do
      let!(:user) { create(:user, :anonymous, :confirmed, :published, organization:) }

      it "shows endorse, follow and comments -buttons" do
        visit_blog_post

        within ".blog__actions" do
          expect(page).to have_link("Follow")
          expect(page).to have_button("Like")
          expect(page).to have_link("Comment")
        end
      end
    end

    context "when user private" do
      it "hides endorse button" do
        visit_blog_post

        within ".blog__actions-left" do
          expect(page).to have_no_button("Like")
          expect(page).to have_link("Comment")
        end
      end
    end

    context "when no signed in user" do
      it "hides endorse button" do
        visit_blog_post

        find_by_id("trigger-dropdown-account").click

        within "#dropdown-menu-account" do
          click_on "Log out"
        end

        within ".blog__actions-left" do
          expect(page).to have_no_button("Like")
        end
      end
    end
  end

  def visit_blog_post
    visit_component
    click_on post.title["en"]
  end
end

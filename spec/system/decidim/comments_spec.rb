# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Comments", type: :system do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when trying to leave a comment on the site" do
    let!(:component) { create(:post_component, participatory_space: participatory_process) }
    let!(:post) { create(:post, component: component) }

    it "gives you a publicity popup for consent, which has to be accepted in order to proceed" do
      comment_blog_post

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
      )

      find("#publish_account_agree_public_profile").check

      click_button "Make your profile public"

      expect(page).to have_content("Hello there!")
    end

    context "when comment left" do
      it "shows author name if user public" do
        user.update(published_at: Time.current)
        comment_blog_post

        within ".comment-thread" do
          within ".author-data" do
            expect(page).to have_content(user.name)
            expect(page).to have_selector("a[href='/profiles/#{user.nickname}']")
          end
        end
      end

      it "hide author name if user private" do
        user.update(published_at: Time.current)
        comment_blog_post

        expect(page).to have_selector(".comment-thread")
        user.update(published_at: nil)
        user.reload

        refresh
        within ".comment-thread" do
          expect(page).not_to have_selector(".author-data")
        end
      end
    end

    context "when comment replied to" do
      it "shows the author name of replier if replier public" do
        reply

        within "#comment-#{Decidim::Comments::Comment.first.id}-replies" do
          expect(page).to have_content(user.name)
          expect(page).to have_selector("a[href='/profiles/#{user.nickname}']")
        end
      end

      it "hides the author name of replier if replier private" do
        reply

        user.update(published_at: nil)
        user.reload

        refresh
        within "#comment-#{Decidim::Comments::Comment.first.id}-replies" do
          expect(page).not_to have_content(user.name)
          expect(page).not_to have_selector("a[href='/profiles/#{user.nickname}']")
        end
      end
    end

    context "when anonymity enabled", :anonymity do
      it "gives you an anonymity popup for consent, which has to be accepted in order to proceed" do
        comment_blog_post

        expect(page).to have_content("Profile publicity")
        expect(page).to have_content(
          "Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others."
        )

        click_button "Continue anonymous"

        expect(page).to have_content("Hello there!")
        expect(page).to have_content("Unnamed participant")
      end

      context "when 'I want my profile to be public' is pressed" do
        it "gives you a publicity popup for consent" do
          comment_blog_post

          expect(page).to have_content("Profile publicity")
          click_button "I want my profile to be public"
          expect(page).to have_content("Make your profile public")
          expect(page).to have_content(
            "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
          )

          find("#publish_account_agree_public_profile").check

          click_button "Make your profile public"

          expect(page).to have_content("Hello there!")
        end
      end
    end
  end

  def comment_blog_post
    visit_component
    expect(page).to have_content(post.title["en"])
    click_link post.title["en"]
    expect(page).to have_css("[data-decidim-comments]")
    fill_in "add-comment-Post-#{post.id}", with: "Hello there!"
    click_button "Send"
  end

  def reply
    user.update(published_at: Time.current)
    comment_blog_post
    expect(page).to have_selector(".comment-thread")

    click_button "Reply"

    fill_in "add-comment-Comment-#{Decidim::Comments::Comment.first.id}", with: "Well hello"
    click_button "Send", match: :first

    expect(page).to have_selector("#comment-#{Decidim::Comments::Comment.first.id}-replies")
  end
end

# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Comments" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when trying to leave a comment on the site" do
    let!(:component) { create(:post_component, participatory_space: participatory_process) }
    let!(:post) { create(:post, component:) }

    it "gives you a publicity popup for consent, which has to be accepted in order to proceed" do
      comment_blog_post

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
      )

      find_by_id("publish_account_agree_public_profile").check

      click_on "Make your profile public"

      expect(page).to have_content("Hello there!")
    end

    context "when comment left" do
      it "shows author name if user public" do
        user.update(published_at: Time.current)
        comment_blog_post

        within ".comment-thread" do
          within ".author" do
            expect(page).to have_content(user.name)
            expect(page).to have_css("a[href='/profiles/#{user.nickname}']")
          end
        end
      end

      it "hide author name if user private" do
        user.update(published_at: Time.current)
        comment_blog_post

        expect(page).to have_css(".comment-thread")
        user.update(published_at: nil)
        user.reload

        refresh
        within ".comment-thread" do
          expect(page).to have_css(".author__name", text: "Unnamed participant")
        end
      end
    end

    context "when comment replied to" do
      it "shows the author name of replier if replier public" do
        reply

        within "#comment-#{Decidim::Comments::Comment.first.id}-replies" do
          expect(page).to have_content(user.name)
          expect(page).to have_css("a[href='/profiles/#{user.nickname}']")
        end
      end

      it "hides the author name of replier if replier private" do
        reply

        user.update(published_at: nil)
        user.reload

        refresh
        within "#comment-#{Decidim::Comments::Comment.first.id}-replies" do
          expect(page).to have_no_content(user.name)
          expect(page).to have_no_selector("a[href='/profiles/#{user.nickname}']")
        end
      end
    end

    context "when anonymity enabled", :anonymity do
      context "when anonymous and part of a user group" do
        let!(:user) { create(:user, :anonymous, :confirmed, organization:) }
        let!(:user_group) { create(:user_group, :confirmed, :verified, users: [user], organization: user.organization) }

        it "create as -field has a help text" do
          visit_component
          click_on post.title["en"]

          within ".new_comment" do
            expect(page).to have_css(".help-text", text: "Your profile is anonymous. If you use your own account for creation, your name is not visible unless you later decide to make your profile public.")
          end
        end
      end

      context "when posting a comment" do
        it "gives you an anonymity popup for consent, which has to be accepted in order to proceed" do
          comment_blog_post

          expect(page).to have_content("Profile publicity")
          expect(page).to have_content(
            "Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others."
          )

          click_on "Continue anonymously"

          expect(page).to have_content("Hello there!")
          expect(page).to have_content("Unnamed participant")
        end
      end

      context "when 'I want my profile to be public' is pressed" do
        it "gives you a publicity popup for consent" do
          comment_blog_post

          expect(page).to have_css("#anonymityModal")
          click_on "I want my profile to be public"
          expect(page).to have_css("#publishAccountModal")

          expect(page).to have_content(
            "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
          )

          find_by_id("publish_account_agree_public_profile").check

          click_on "Make your profile public"

          expect(page).to have_content("Hello there!")
        end
      end
    end
  end

  def comment_blog_post
    visit_component
    click_on post.title["en"]
    fill_in "add-comment-Post-#{post.id}", with: "Hello there!"
    click_on "Publish comment"
  end

  def reply
    user.update(published_at: Time.current)
    comment_blog_post
    expect(page).to have_css(".comment-thread")

    click_on "Reply"

    fill_in "add-comment-Comment-#{Decidim::Comments::Comment.first.id}", with: "Well hello"
    click_on "Publish reply", match: :first

    expect(page).to have_css("#comment-#{Decidim::Comments::Comment.first.id}-replies")
  end
end

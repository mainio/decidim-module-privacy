# frozen_string_literal: true

require "spec_helper"

describe "Conversations", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { (create :participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:receiver) { create(:user, :confirmed, organization: organization) }
  let!(:group_chat_participant) { create(:user, :confirmed, organization: organization) }
  let!(:user_group) { create(:user_group, :confirmed, :verified, organization: organization) }

  before do
    switch_to_host(organization.host)
    user.update(published_at: Time.current)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when searching for users in 'new conversation'" do
    context "when receiver profile is private" do
      it "does not show up in the search" do
        visit decidim.conversations_path

        click_button "New conversation"
        fill_in "add_conversation_users", with: receiver.name

        expect(page).not_to have_selector("#autoComplete_list_1")
      end
    end

    context "when receiver has private messaging disabled" do
      it "does not allow to initiate the conversation" do
        receiver.update(published_at: Time.current, allow_private_messaging: false)
        group_chat_participant.update(published_at: Time.current)

        visit decidim.conversations_path
        click_on "New conversation"

        fill_in "add_conversation_users", with: receiver.name

        within "#autoComplete_result_0" do
          expect(page).to have_content("This participant does not want to receive private messages")
        end
      end
    end
  end

  context "when searching for user groups in 'new conversation'" do
    context "when user group is verified and confirmed" do
      it "shows up in the search" do
        visit decidim.conversations_path

        click_button "New conversation"
        fill_in "add_conversation_users", with: user_group.name

        expect(page).to have_selector("#autoComplete_list_1")
      end
    end

    context "when user group is not verified" do
      it "does not show up in the search" do
        user_group.update(extended_data: { verified_at: nil })
        visit decidim.conversations_path

        click_button "New conversation"
        fill_in "add_conversation_users", with: user_group.name

        expect(page).not_to have_selector("#autoComplete_list_1")
      end
    end

    context "when user group is not confirmed" do
      it "does not show up in the search" do
        user_group.update(confirmed_at: nil)
        visit decidim.conversations_path

        click_on "New conversation"
        fill_in "add_conversation_users", with: user_group.name

        expect(page).to have_no_css("#autoComplete_list_1")
      end
    end
  end

  context "when own profile private" do
    it "does not have 'conversations' link in the user menu" do
      user.update(published_at: nil)
      refresh

      within "div.main-bar__dropdown-container" do
        find_by_id("trigger-dropdown-account").click
      end

      expect(page).to have_no_link("Conversations")
    end

    it "renders a page telling the user that the account is private if trying to access 'conversations' page" do
      user.update(published_at: nil)
      refresh

      visit decidim.conversations_path

      expect(page).to have_content("Private messaging is not enabled")
    end

    it "does not show 'conversations' link in the navbar" do
      user.update(published_at: nil)
      refresh
      expect(page).not_to have_selector(".icon--envelope-closed")
    end
  end

  context "when receiver profile is private" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim.profile_path(nickname: receiver.nickname) }
    end
  end

  context "when two person conversation" do
    context "when starting a conversation with a user group" do
      it "is possible even if user group is private" do
        user_group_conversation

        within ".conversation__message-text" do
          expect(page).to have_content("Hello there receiver!")
        end
      end

      it "is possible even if user group has private messaging disabled" do
        user_group.update(published_at: Time.current, allow_private_messaging: false)
        user_group_conversation

        within ".conversation__message-text" do
          expect(page).to have_content("Hello there receiver!")
        end
      end
    end

    context "when starting conversation" do
      context "when receiver profile has private messaging turned off" do
        it "blocks people from sending messages to them" do
          receiver.update(published_at: Time.current, allow_private_messaging: false)
          visit decidim.profile_path(nickname: receiver.nickname)

          expect(page).to have_css("button[title='This participant does not accept direct messages.'][disabled]")
        end
      end
    end

    context "when conversation already established" do
      context "when receiver profile turns private messaging off" do
        it "shows the message history but blocks the possibility of replying" do
          start_conversation

          initiate_convo

          receiver.update(allow_private_messaging: false)
          refresh

          expect(page).to have_content("Conversation with")
          expect(page).to have_content(receiver.name)
          expect(page).to have_content("Hello there receiver!")
          expect(page).to have_content("Hello there user!")
          expect(page).to have_content("You cannot have a conversation with a participant that has private messaging disabled.")
          expect(page).to have_css("a[href='/profiles/#{receiver.nickname}']")
        end
      end

      context "when receiver profile turns private" do
        it "shows the message history but blocks the possibility of replying" do
          start_conversation

          initiate_convo

          receiver.update(published_at: nil)
          refresh

          expect(page).to have_content("Conversation with")
          expect(page).to have_content("Unnamed participant")
          expect(page).to have_content("Hello there receiver!")
          expect(page).to have_content("Hello there user!")
          expect(page).to have_content("You cannot have a conversation with a private participant.")
          expect(page).to have_no_css("a[href='/profiles/#{receiver.nickname}']")
        end
      end
    end
  end

  context "when group conversation" do
    context "when starting a group conversation with a user group and the user group is private" do
      it "is possible to start the group conversation" do
        receiver.update(published_at: Time.current)

        visit decidim.conversations_path
        click_on "New conversation"
        fill_in "add_conversation_users", with: receiver.name
        find_by_id("autoComplete_result_0").click

        fill_in "add_conversation_users", with: user_group.name
        find_by_id("autoComplete_result_0").click
        click_on "Next"

        expect(page).to have_content("Conversation with")
        fill_in "conversation_body", with: "Hello there receiver!"

        click_on "Send"

        within ".conversation__message-text" do
          expect(page).to have_content("Hello there receiver!")
        end
      end
    end

    context "when a group conversation established and one user goes private" do
      it "shows the user as private but shows all messages" do
        receiver.update(published_at: Time.current)
        group_chat_participant.update(published_at: Time.current)

        visit decidim.conversations_path

        click_on "New conversation"

        fill_in "add_conversation_users", with: receiver.name
        find_by_id("autoComplete_result_0").click

        fill_in "add_conversation_users", with: group_chat_participant.name
        find_by_id("autoComplete_result_0").click

        click_on "Next"

        expect(page).to have_content("Conversation with")

        fill_in "conversation_body", with: "Hello there receiver!"

        click_on "Send"

        initiate_convo

        receiver.update(published_at: nil)
        refresh

        expect(page).to have_content("Conversation with")
        expect(page).to have_content("Unnamed participant")
        expect(page).to have_content(group_chat_participant.name)
        expect(page).to have_content("Hello there receiver!")
        expect(page).to have_content("Hello there user!")
      end
    end

    context "when a group conversation established and one user turns private messaging off" do
      it "shows who has disabled private messaging but shows all messages" do
        receiver.update(published_at: Time.current)
        group_chat_participant.update(published_at: Time.current)

        visit decidim.conversations_path

        click_on "New conversation"

        fill_in "add_conversation_users", with: receiver.name
        find_by_id("autoComplete_result_0").click

        fill_in "add_conversation_users", with: group_chat_participant.name
        find_by_id("autoComplete_result_0").click

        click_on "Next"

        expect(page).to have_content("Conversation with")

        fill_in "conversation_body", with: "Hello there receiver!"

        click_on "Send"

        initiate_convo

        receiver.update(allow_private_messaging: false)
        refresh

        expect(page).to have_content("Conversation with")
        expect(page).to have_content(receiver.name)
        expect(page).to have_content(group_chat_participant.name)
        expect(page).to have_content("The following participant has disabled their private messaging: #{receiver.name}")
        expect(page).to have_content("Hello there receiver!")
        expect(page).to have_content("Hello there user!")
      end
    end
  end

  def initiate_convo
    within ".conversation__message-text" do
      expect(page).to have_content("Hello there receiver!")
    end

    login_as receiver, scope: :user

    visit decidim.conversations_path

    find("#conversation-#{Decidim::Messaging::Conversation.first.id}").click

    fill_in "message_body", with: "Hello there user!"

    click_on "Send"

    expect(page).to have_content("Hello there user!")

    login_as user, scope: :user
    expect(page).to have_content(user.name)
    visit decidim.conversations_path

    find("#conversation-#{Decidim::Messaging::Conversation.first.id}").click
  end

  def start_conversation
    receiver.update(published_at: Time.current)
    visit decidim.profile_path(nickname: receiver.nickname)

    within ".profile__actions-main" do
      find("a[title='Message']").click
    end

    fill_in "conversation_body", with: "Hello there receiver!"
    click_on "Send"
  end

  def user_group_conversation
    visit decidim.profile_path(nickname: user_group.nickname)
    within ".profile__actions-main" do
      find("a[title='Message']").click
    end

    fill_in "conversation_body", with: "Hello there receiver!"
    click_on "Send"
  end
end

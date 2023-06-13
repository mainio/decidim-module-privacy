# frozen_string_literal: true

require "spec_helper"

describe "Conversations", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { (create :participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:receiver) { create(:user, :confirmed, organization: organization) }
  let!(:group_chat_participant) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    user.update(published_at: Time.current)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when profile has private messaging turned off" do
    it "blocks people from sending messages to them" do
      receiver.update(published_at: Time.current, allow_private_messaging: false)
      visit decidim.profile_path(nickname: receiver.nickname)

      find(".user-contact_link").click

      expect(page).to have_content("Private user")
      expect(page).to have_content("You can't have a conversation with an account that is private or has messaging disabled.")
    end

    it "doesn't show up in the 'new conversation' search" do
      receiver.update(published_at: Time.current, allow_private_messaging: false)
      visit decidim.conversations_path

      click_button "New conversation"
      fill_in "add_conversation_users", with: receiver.name
      expect(page).not_to have_selector("#autoComplete_list_1")
    end
  end

  context "when profile is private" do
    it "doesn't allow user to visit the profile page" do
      receiver.update(published_at: nil)
      expect do
        visit decidim.profile_path(nickname: receiver.nickname)
        expect(page).to have_content(receiver.name)
      end.to raise_error(ActionController::RoutingError)
    end

    it "doesn't show up in the 'new conversation' search" do
      receiver.update(published_at: nil)

      visit decidim.conversations_path

      click_button "New conversation"
      fill_in "add_conversation_users", with: receiver.name
      expect(page).not_to have_selector("#autoComplete_list_1")
    end

    it "doesn't have 'conversations' link in the user menu" do
      user.update(published_at: nil)
      refresh

      click_link user.name

      expect(page).not_to have_link("Conversations")
    end

    it "renders a page telling the user that the account is private if trying to access 'conversations' page" do
      user.update(published_at: nil)
      refresh

      visit decidim.conversations_path

      expect(page).to have_content("Private messaging is not enabled")
    end

    it "doesn't show 'conversations' link in the navbar" do
      user.update(published_at: nil)
      refresh
      expect(page).not_to have_selector(".icon--envelope-closed")
    end
  end

  context "when profile is public" do
    it "shows 'conversations' link in the navbar" do
      expect(page).to have_selector(".icon--envelope-closed")
    end

    it "has 'conversations' link in the user menu" do
      click_link user.name
      expect(page).to have_link("Conversations")
    end
  end

  context "when profile has private messaging turned on and is public" do
    it "allows people to start a conversation with them" do
      start_conversation

      expect(page).to have_selector(".p-s")
      expect(page).to have_content("Hello there receiver!")
    end

    it "shows up in the 'new conversation' search" do
      receiver.update(published_at: Time.current)
      visit decidim.conversations_path

      click_button "New conversation"
      fill_in "add_conversation_users", with: receiver.name
      expect(page).to have_selector("#autoComplete_list_1")
    end

    context "when profile turns private messaging off after you have started a conversation with them" do
      it "shows the message history but blocks the possibility of replying" do
        start_conversation

        initiate_convo

        receiver.update(allow_private_messaging: false)
        refresh

        expect(page).to have_content("Conversation with")
        expect(page).to have_content("Private user")
        expect(page).to have_content("Hello there receiver!")
        expect(page).to have_content("Hello there user!")
        expect(page).to have_content("You can't have a conversation with an account that is private or has messaging disabled.")
      end
    end

    context "when profile goes private after you have started a conversation with them" do
      it "shows the message history but blocks the possibility of replying" do
        start_conversation

        initiate_convo

        receiver.update(published_at: nil)
        refresh

        expect(page).to have_content("Conversation with")
        expect(page).to have_content("Private user")
        expect(page).to have_content("Hello there receiver!")
        expect(page).to have_content("Hello there user!")
        expect(page).to have_content("You can't have a conversation with an account that is private or has messaging disabled.")
      end
    end
  end

  context "when starting a group chat and one user goes private" do
    it "shows the user as private but shows all messages" do
      receiver.update(published_at: Time.current)
      group_chat_participant.update(published_at: Time.current)

      visit decidim.conversations_path

      click_button "New conversation"

      fill_in "add_conversation_users", with: receiver.name
      find("#autoComplete_result_0").click

      fill_in "add_conversation_users", with: group_chat_participant.name
      find("#autoComplete_result_0").click

      click_button "Next"

      expect(page).to have_content("START A CONVERSATION")

      fill_in "conversation_body", with: "Hello there receiver!"

      click_button "Send"

      initiate_convo

      receiver.update(published_at: nil)
      refresh

      expect(page).to have_content("Conversation with")
      expect(page).to have_content("Private user")
      expect(page).to have_content(group_chat_participant.name)
      expect(page).to have_content("Hello there receiver!")
      expect(page).to have_content("Hello there user!")
    end
  end

  def initiate_convo
    expect(page).to have_selector(".p-s")
    expect(page).to have_content("Hello there receiver!")

    login_as receiver, scope: :user

    visit decidim.conversations_path

    find("#conversation-#{Decidim::Messaging::Conversation.first.id}").click

    fill_in "message_body", with: "Hello there user!"

    click_button "Send"

    expect(page).to have_content("Hello there user!")

    login_as user, scope: :user

    visit decidim.conversations_path

    find("#conversation-#{Decidim::Messaging::Conversation.first.id}").click
  end

  def start_conversation
    receiver.update(published_at: Time.current, allow_private_messaging: true)
    visit decidim.profile_path(nickname: receiver.nickname)

    find(".user-contact_link").click
    fill_in "conversation_body", with: "Hello there receiver!"
    click_button "Send"
  end
end

# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::ConversationHelper do
  describe "#conversation_label_for" do
    let(:user) { create :user, :confirmed }
    let(:participants) { [user] }

    before do
      helper.instance_variable_set(:@virtual_path, "decidim.messaging.conversations.show")
    end

    it "does not includes the user name for private users" do
      expect(helper.conversation_label_for(participants)).to eq "Conversation with Private participant"
    end

    context "when public user" do
      let(:user) { create :user, :confirmed, :published }

      it "includes the user name" do
        expect(helper.conversation_label_for(participants)).to eq "Conversation with #{user.name} (@#{user.nickname})"
      end
    end

    context "when user is deleted" do
      let(:user) { create :user, :deleted }

      it "does not include the user name" do
        expect(helper.conversation_label_for(participants)).to eq "Conversation with Participant deleted"
      end
    end
  end

  describe "#username_list" do
    let(:user) { create :user, :confirmed }
    let(:participants) { [user] }

    before do
      helper.instance_variable_set(:@virtual_path, "decidim.messaging.conversations.show")
    end

    context "when private user" do
      it "includes the user name" do
        expect(helper.username_list(participants)).to eq "<span class=\"label label--small label--basic\">Private participant</span>"
      end
    end

    context "when public user" do
      let(:user) { create :user, :confirmed, :published }

      it "includes the user name" do
        expect(helper.username_list(participants)).to eq "<strong>#{user.name}</strong>"
      end
    end

    context "when user is deleted" do
      let(:user) { create :user, :deleted }

      it "does not include the user name" do
        expect(helper.username_list(participants)).to eq "<span class=\"label label--small label--basic\">Participant deleted</span>"
      end
    end
  end

  describe "#conversation_name_for" do
    let(:user) { create :user, :confirmed }
    let(:participants) { [user] }

    before do
      helper.instance_variable_set(:@virtual_path, "decidim.messaging.conversations.show")
    end

    context "when user is public" do
      let(:user) { create :user, :confirmed, :published }

      it "includes the user name" do
        expect(helper.conversation_name_for(participants)).to eq "<strong>#{user.name}</strong><br><span class=\"muted\">@#{user.nickname}</span>"
      end
    end

    context "when private user" do
      it "includes the user name" do
        expect(helper.conversation_name_for(participants)).to eq "<span class=\"label label--small label--basic\">Private participant</span><br><span class=\"muted\"><i>This participant has decided to make their profile private. New messages to this conversation have been therefore disabled.</i></span>"
      end
    end

    context "when user is deleted" do
      let(:user) { create :user, :deleted }

      it "does not include the user name" do
        expect(helper.conversation_name_for(participants)).to eq "<span class=\"label label--small label--basic\">Participant deleted</span>"
      end
    end
  end
end

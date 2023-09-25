# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::StartConversationExtensions do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:receiver) { create(:user, :confirmed, organization: organization) }

  let(:form_params) do
    {
      body: "Hello there receiver!",
      recipient_id: receiver.id
    }
  end

  let(:form) do
    Decidim::Messaging::ConversationForm.from_params(
      form_params
    ).with_context(
      current_user: user,
      sender: user
    )
  end

  let(:command) { Decidim::Messaging::StartConversation.new(form) }

  before do
    user.update(published_at: Time.current)
  end

  context "when public user with messages enabled" do
    it "broadcasts ok" do
      receiver.update(published_at: Time.current)

      expect do
        command.call
      end.to broadcast(:ok)
    end
  end

  context "when a private user" do
    it "broadcasts invalid" do
      expect do
        command.call
      end.to broadcast(:invalid)
    end
  end

  context "when public user with messages disabled" do
    it "broadcasts invalid" do
      receiver.update(published_at: Time.current, allow_private_messaging: false)

      expect do
        command.call
      end.to broadcast(:invalid)
    end
  end

  context "when starting a conversation to multiple participants" do
    let(:participant) { create(:user, :confirmed, organization: organization) }

    let(:form_params) do
      {
        body: "Hello there people!",
        recipient_id: [receiver.id, participant.id]
      }
    end

    context "when 1 participant has private messaging disabled" do
      it "broadcasts invalid" do
        receiver.update(published_at: Time.current, allow_private_messaging: false)
        participant.update(published_at: Time.current)

        expect do
          command.call
        end.to broadcast(:invalid)
      end
    end

    context "when 1 participant is private" do
      it "broadcasts invalid" do
        receiver.update(published_at: Time.current)
        command.call

        expect do
          command.call
        end.to broadcast(:invalid)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Privacy
    describe ReplyToConversationExtensions do
      let(:organization) { create(:organization) }
      let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:receiver) { create(:user, :confirmed, organization: organization) }

      let(:form_params) do
        { body: "Hello there receiver!" }
      end

      let(:form) do
        Decidim::Messaging::MessageForm.from_params(
          form_params
        ).with_context(
          current_user: user,
          sender: user
        )
      end

      let(:conversation) do
        Decidim::Messaging::Conversation.start!(
          originator: user,
          interlocutors: [receiver],
          body: "Initial message"
        )
      end

      let!(:participationuser) { Decidim::Messaging::Participation.new(decidim_conversation_id: conversation.id, decidim_participant_id: user.id) }
      let!(:participationreceiver) { Decidim::Messaging::Participation.new(decidim_conversation_id: conversation.id, decidim_participant_id: receiver.id) }

      let(:command) { Decidim::Messaging::ReplyToConversation.new(conversation, form) }

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
        it "doesn't broadcast ok" do
          expect do
            command.call
          end.not_to broadcast(:ok)
        end
      end

      context "when public user with messages disabled" do
        it "doesn't broadcast ok" do
          receiver.update(published_at: Time.current, allow_private_messaging: false)

          expect do
            command.call
          end.not_to broadcast(:ok)
        end
      end

      context "when multiple participants in a initialized conversation" do
        let(:participant) { create(:user, :confirmed, organization: organization) }
        let(:conversation) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [receiver, participant],
            body: "Initial message"
          )
        end

        let(:form_params) do
          { body: "Hello there people!" }
        end

        context "when 1 participant has private messaging disabled" do
          it "broadcasts ok" do
            receiver.update(published_at: Time.current, allow_private_messaging: false)
            participant.update(published_at: Time.current)

            expect do
              command.call
            end.to broadcast(:ok)
          end
        end

        context "when 1 participant is private" do
          it "broadcasts ok" do
            participant.update(published_at: Time.current)

            expect do
              command.call
            end.to broadcast(:ok)
          end
        end
      end
    end
  end
end

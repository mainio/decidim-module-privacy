# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Messaging
    class ConversationsController < Decidim::ApplicationController
      include ::Decidim::Privacy::ConversationsControllerExtensions
    end
    describe ConversationsController, type: :controller do
      routes { Decidim::Core::Engine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:user1) { create(:user, organization: organization) }
      let!(:conversation2) do
        Messaging::Conversation.start!(
          originator: user,
          interlocutors: [user1],
          body: "Hi!"
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET new" do
        subject { get :new, params: { recipient_id: user.id } }
        context "when is private user" do
          it "renders 404 error" do
            expect(subject).to render_template("decidim/privacy/message_block")
          end
        end

        context "when messaging is disabled" do
          let!(:user) { create(:user, :confirmed, organization: organization, allow_private_messaging: false, published_at: Time.current) }

          it "renders 404 error" do
            expect(subject).to render_template("decidim/privacy/message_block")
          end
        end

        context "when is public and private messaing is enabled" do
          let!(:user) { create(:user, :confirmed, organization: organization, published_at: Time.current) }

          context "when is the same user" do
            it "redirects to previous 2 participant created conversation" do
              expect(subject).to redirect_to profile_path(user.nickname)
            end
          end

          context "when conversation with a private user" do
            subject { get :new, params: { recipient_id: user1.id } }
            let!(:user) { create(:user, :confirmed, organization: organization, published_at: Time.current) }

            it "redirects to previous 2 participant created conversation" do
              expect(subject).to redirect_to profile_path(user.nickname)
            end
          end

          context "when conversation with a public user" do
            subject { get :new, params: { recipient_id: user1.id } }
            let!(:user) { create(:user, :confirmed, organization: organization, published_at: Time.current) }
            let!(:user1) { create(:user, organization: organization, published_at: Time.current) }

            it "redirects to previous 2 participant created conversation" do
              expect(subject).to redirect_to conversation_path(conversation2)
            end
          end
        end
      end
    end
  end
end

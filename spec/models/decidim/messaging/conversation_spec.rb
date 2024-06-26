# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Conversation do
  describe ".start_conversation" do
    subject { conversation }

    let(:originator) { create(:user) }
    let(:public_interlocutor) { create(:user, :published) }
    let(:private_interlocutor) { create(:user) }
    let(:from) { nil }
    let(:receipts) { conversation.receipts }

    let(:conversation) do
      described_class.start!(
        originator:,
        interlocutors: [public_interlocutor, private_interlocutor],
        body: "Hei!"
      )
    end

    describe "#participants" do
      before do
        allow(public_interlocutor).to receive(:accepts_conversation?).and_return(true)
        allow(private_interlocutor).to receive(:accepts_conversation?).and_return(true)
      end

      it "contains entire collection" do
        expect(subject.participants).to include(private_interlocutor)
        expect(subject.participants).to include(public_interlocutor)
      end
    end
  end
end

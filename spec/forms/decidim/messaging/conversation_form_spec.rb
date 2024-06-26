# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::ConversationForm do
  subject { form }

  let(:body) { "Hi!" }
  let(:recipient_id) { create(:user, organization: sender.organization, published_at: Time.current).id }
  let(:sender) { create(:user) }
  let(:params) do
    {
      body:,
      recipient_id:
    }
  end
  let(:form) do
    described_class.from_params(params).with_context(sender:)
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when private recipient" do
    let!(:recipient_id) { create(:user, organization: sender.organization).id }

    it { is_expected.not_to be_valid }
  end
end

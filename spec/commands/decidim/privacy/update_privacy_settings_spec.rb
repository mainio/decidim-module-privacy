# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::UpdatePrivacySettings do
  subject { described_class.new(user, form) }

  let!(:user) { create(:user) }
  let(:allow_public_contact) { false }
  let(:allow_private_messaging) { false }

  let(:form) do
    double(
      valid?: valid?,
      anonymity: nil,
      allow_private_messaging: allow_private_messaging,
      allow_public_contact: allow_public_contact,
      published_at: true,
      direct_message_types: "followed-only"
    )
  end

  context "when form is invalid" do
    let(:valid?) { false }

    it { is_expected.to broadcast(:invalid) }
  end

  context "when valid form" do
    let(:valid?) { true }

    it { is_expected.to broadcast(:ok) }

    it "changes user privacy to public" do
      expect(user.published_at).to be_nil
      expect(user.allow_private_messaging).to be_truthy
      expect(user.direct_message_types).to eq("all")
      subject.call
      user = Decidim::User.last
      expect(user.published_at).not_to be_nil
      expect(user.allow_private_messaging).to be_falsey
      expect(user.direct_message_types).to eq("followed-only")
    end
  end
end

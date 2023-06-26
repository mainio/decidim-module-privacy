# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::UpdateAccountPublicity do
  subject { described_class.new(user, form) }

  let!(:user) { create(:user) }
  let(:form) do
    double(
      valid?: valid?
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
      subject.call
      publicity = Decidim::User.last.published_at
      expect(publicity).not_to be_nil
    end
  end
end

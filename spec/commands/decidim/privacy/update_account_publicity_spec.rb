# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::UpdateAccountPublicity do
  subject { described_class.new(user, form) }

  let!(:user) { create(:user) }
  let(:agree_public_profile) { "1" }
  let(:form) do
    double(
      valid?: valid?,
      agree_public_profile: agree_public_profile
    )
  end

  context "when form is invalid" do
    let(:valid?) { false }

    it "broadcasts invlaide" do
      expect(subject.call).to broadcast(:invalid)
    end
  end

  context "when valid form" do
    let(:valid?) { true }

    it "broadcasts invlaide" do
      expect(subject.call).to broadcast(:ok)
    end

    context "when accepts the publicity" do
      it "changes user privacy to public" do
        expect(user.published_at).to be_nil
        subject.call
        publicity = Decidim::User.last.published_at
        expect(publicity).not_to be_nil
      end
    end
  end
end

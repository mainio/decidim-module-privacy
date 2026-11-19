# frozen_string_literal: true

require "spec_helper"

describe Decidim::Identity do
  let!(:identity) { create(:identity, user:) }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }

  describe "#user" do
    subject { Decidim::Identity.last.user }

    it "knows its user" do
      expect(subject).to eq(user)
    end

    context "when user anonymous", :anonymity do
      let(:user) { create(:user, :anonymous, :confirmed, organization:) }

      it "knows its user" do
        expect(subject).to eq(user)
      end
    end
  end
end

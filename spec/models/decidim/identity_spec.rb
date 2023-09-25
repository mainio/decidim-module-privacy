# frozen_string_literal: true

require "spec_helper"

describe Decidim::Identity do
  let!(:identity) { create(:identity, user: user) }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  describe "#user" do
    subject { Decidim::Identity.last.user }

    it "knows its user" do
      expect(subject).to eq(user)
    end
  end
end

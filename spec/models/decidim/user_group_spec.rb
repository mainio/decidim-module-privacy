# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroup do
  subject { described_class }

  describe "usergroup extension" do
    let!(:organization) { create(:organization) }
    let(:private_verified) { create(:user_group, :verified, organization:) }

    let(:private_confirmed) { create(:user_group, :confirmed, organization:) }
    let(:public_verified) { create(:user_group, :confirmed, :verified, published_at: Time.current, organization:) }
    let!(:public_confirmed) { create(:user_group, :confirmed, published_at: Time.current, organization:) }

    describe "#scopes" do
      it "returns visibles by default" do
        result = subject.all

        expect(result).to include(public_verified)
        expect(result).not_to include(private_verified)
        expect(result).not_to include(private_confirmed)
        expect(result).not_to include(public_confirmed)
      end

      it "returns entire collextion correctly" do
        result = subject.entire_collection

        expect(result).to include(public_verified)
        expect(result).to include(private_verified)
        expect(result).to include(private_confirmed)
        expect(result).to include(public_confirmed)
      end
    end
  end
end

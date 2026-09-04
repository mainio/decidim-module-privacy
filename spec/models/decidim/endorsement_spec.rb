# frozen_string_literal: true

require "spec_helper"

describe Decidim::Endorsement do
  let(:organization) { create(:organization) }
  let(:component) { create(:proposal_component, organization:) }
  let(:proposal) { create(:proposal, component:) }

  let!(:published_user) { create(:user, :confirmed, organization:, published_at: Time.current) }
  let!(:unpublished_user) { create(:user, :confirmed, organization:, published_at: nil) }

  let!(:endorsement_by_published) { create(:endorsement, resource: proposal, author: published_user) }
  let!(:endorsement_by_unpublished) { create(:endorsement, resource: proposal, author: unpublished_user) }

  describe "default_scope" do
    it "includes endorsements by published users" do
      expect(Decidim::Endorsement.all).to include(endorsement_by_published)
    end

    it "excludes endorsements by unpublished users" do
      expect(Decidim::Endorsement.all).not_to include(endorsement_by_unpublished)
    end

    it "returns correct count" do
      expect(Decidim::Endorsement.count).to eq(1)
    end
  end

  describe "unscoped" do
    it "returns all endorsements including unpublished authors" do
      expect(Decidim::Endorsement.unscoped.count).to eq(2)
    end
  end

  describe ".with_visible_authors" do
    it "excludes endorsements from unpublished users" do
      results = Decidim::Endorsement.unscoped.with_visible_authors
      expect(results).to include(endorsement_by_published)
      expect(results).not_to include(endorsement_by_unpublished)
    end
  end

  context "when user becomes published" do
    it "endorsement becomes visible" do
      expect(Decidim::Endorsement.all).not_to include(endorsement_by_unpublished)

      unpublished_user.update!(published_at: Time.current)

      expect(Decidim::Endorsement.all).to include(endorsement_by_unpublished)
    end
  end
end

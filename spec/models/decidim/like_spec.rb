# frozen_string_literal: true

require "spec_helper"

describe Decidim::Like do
  let(:organization) { create(:organization) }
  let(:component) { create(:proposal_component, organization:) }
  let(:proposal) { create(:proposal, component:) }

  let!(:published_user) { create(:user, :confirmed, organization:, published_at: Time.current) }
  let!(:unpublished_user) { create(:user, :confirmed, organization:, published_at: nil) }

  let!(:like_by_published) { create(:like, resource: proposal, author: published_user) }
  let!(:like_by_unpublished) { create(:like, resource: proposal, author: unpublished_user) }

  describe "default_scope" do
    it "includes likes by published users" do
      expect(Decidim::Like.all).to include(like_by_published)
    end

    it "excludes likes by unpublished users" do
      expect(Decidim::Like.all).not_to include(like_by_unpublished)
    end

    it "returns correct count" do
      expect(Decidim::Like.count).to eq(1)
    end
  end

  describe "unscoped" do
    it "returns all likes including unpublished authors" do
      expect(Decidim::Like.unscoped.count).to eq(2)
    end
  end

  describe ".with_visible_authors" do
    it "excludes likes from unpublished users" do
      results = Decidim::Like.unscoped.with_visible_authors
      expect(results).to include(like_by_published)
      expect(results).not_to include(like_by_unpublished)
    end
  end

  context "when user becomes published" do
    it "like becomes visible" do
      expect(Decidim::Like.all).not_to include(like_by_unpublished)

      unpublished_user.update!(published_at: Time.current)

      expect(Decidim::Like.all).to include(like_by_unpublished)
    end
  end
end

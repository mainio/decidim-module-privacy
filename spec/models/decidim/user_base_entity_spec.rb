# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserBaseEntity do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:published_user) { create(:user, :confirmed, :published, organization: organization) }
  let(:private_user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  describe "#default_scope" do
    it "returns only published profiles by default" do
      expect(subject.all).to include(published_user)
      expect(subject.all).not_to include(private_user)
      expect(subject.all).to include(user_group)
    end
  end

  describe "#entire_collection" do
    it "returns entire collection" do
      expect(subject.entire_collection.all).to include(published_user)
      expect(subject.entire_collection.all).to include(private_user)
      expect(subject.entire_collection.all).to include(user_group)
    end
  end
end

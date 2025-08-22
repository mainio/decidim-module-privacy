# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserBaseEntity, :anonymity do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:published_user) { create(:user, :confirmed, :published, organization:) }
  let(:private_user) { create(:user, :confirmed, organization:) }
  let(:anonymous_user) { create(:user, :anonymous, :confirmed, organization:) }
  let(:user_group) { create(:user_group, organization:) }

  describe "#default_scope" do
    it "returns only published profiles by default" do
      expect(subject.all).to include(published_user)
      expect(subject.all).not_to include(private_user)
      expect(subject.all).not_to include(anonymous_user)
      expect(subject.all).to include(user_group)
    end
  end

  describe "#entire_collection" do
    it "returns entire collection" do
      expect(subject.entire_collection.all).to include(published_user)
      expect(subject.entire_collection.all).to include(private_user)
      expect(subject.entire_collection.all).to include(anonymous_user)
      expect(subject.entire_collection.all).to include(user_group)
    end
  end

  describe ".nicknamize" do
    context "when private users occupy potential nickname" do
      let!(:first_user) { create(:user, :confirmed, nickname: "john_doe") }
      let!(:second_user) { create(:user, :confirmed, nickname: "john_doe_1") }
      let!(:third_user) { create(:user, :confirmed, nickname: "john_doe_2") }
      let!(:fourth_user) { create(:user, :confirmed, nickname: "john_doe_3") }

      it "returns a unique nickname when a private user has already taken the given nickname" do
        expect(described_class.nicknamize("John Doe")).to eq("john_doe_4")
      end
    end

    context "when anonymous users occupy potential nickname" do
      let!(:first_user) { create(:user, :anonymous, :confirmed, nickname: "jane_doe") }
      let!(:second_user) { create(:user, :anonymous, :confirmed, nickname: "jane_doe_1") }
      let!(:third_user) { create(:user, :anonymous, :confirmed, nickname: "jane_doe_2") }
      let!(:fourth_user) { create(:user, :anonymous, :confirmed, nickname: "jane_doe_3") }

      it "returns a unique nickname when a private user has already taken the given nickname" do
        expect(described_class.nicknamize("Jane Doe")).to eq("jane_doe_4")
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe Decidim::User do
  subject { described_class }

  let!(:organization) { create(:organization) }
  let!(:published_user) { create(:user, :confirmed, :published, organization:) }
  let!(:private_user) { create(:user, :confirmed, organization:) }

  describe ".default_scope" do
    subject { described_class.all }

    it "returns only published users by default" do
      expect(subject).to include(published_user)
      expect(subject).not_to include(private_user)
    end
  end

  describe ".entire_collection" do
    subject { described_class.entire_collection }

    it "rerutns entire_collection when scoped" do
      expect(subject).to include(published_user)
      expect(subject).to include(private_user)
    end
  end

  describe ".profile_published" do
    subject { described_class.profile_published }

    it "returns the published users only" do
      expect(subject).to include(published_user)
      expect(subject).not_to include(private_user)
    end
  end

  describe ".profile_private" do
    subject { described_class.profile_private }

    it "returns private when scoped" do
      expect(subject).not_to include(published_user)
      expect(subject).to include(private_user)
    end
  end

  describe ".find_for_authentication" do
    subject { described_class.find_for_authentication(conditions) }

    let(:conditions) { { email: private_user.email, env: { "decidim.current_organization" => organization } } }

    it "finds the private user for authentication" do
      expect(subject).to eq(private_user)
    end
  end

  describe ".user_collection" do
    subject { described_class.user_collection(private_user) }

    it "finds the private user for export" do
      expect(subject.count).to eq(1)
      expect(subject).to include(private_user)
    end
  end

  describe "#public?" do
    it "return true if user is public" do
      expect(private_user).not_to be_public
      expect(published_user).to be_public
    end
  end

  describe "#private_messaging_disabled?" do
    it "returns true only if use is public and disabled messaging" do
      expect(private_user).not_to be_private_messaging_disabled
      expect do
        published_user.update(allow_private_messaging: false)
      end.to change(published_user, :private_messaging_disabled?).from(false).to(true)
    end
  end

  describe "#private_or_no_messaging?" do
    it "returns true if private or no_messaging" do
      expect(private_user).to be_private_or_no_messaging
      expect do
        published_user.update(allow_private_messaging: false)
      end.to change(published_user, :private_or_no_messaging?).from(false).to(true)
    end
  end

  describe "#accepts_conversation?" do
    let!(:user) { create(:user, :published, :confirmed, organization:) }

    it "returns false if private messaging is turned off" do
      published_user.update(allow_private_messaging: false)

      expect(published_user.accepts_conversation?(user)).to be(false)
    end
  end
end

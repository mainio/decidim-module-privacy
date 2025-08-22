# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserPresenter, :anonymity, type: :helper do
  let(:user) { build(:user) }

  describe "#nickname" do
    subject { described_class.new(user).nickname }

    context "when blocked" do
      before do
        user.blocked = true
      end

      it { is_expected.to eq("") }
    end

    context "when private" do
      it { is_expected.to eq("") }
    end

    context "when anonymous" do
      before do
        user.anonymity = true
      end

      it { is_expected.to eq("") }
    end

    context "when not blocked & public" do
      before do
        user.published_at = Time.current
      end

      it { is_expected.to eq("@#{user.nickname}") }
    end
  end

  describe "#profile_url" do
    subject { described_class.new(user).profile_url }

    context "when private" do
      it { is_expected.to eq("") }
    end

    context "when anonymous" do
      before do
        user.anonymity = true
      end

      it { is_expected.to eq("") }
    end

    context "when public" do
      before do
        user.published_at = Time.current
      end

      it { is_expected.to eq("http://#{user.organization.host}:#{Capybara.server_port}/profiles/#{user.nickname}") }
    end
  end

  describe "#default_avatar_url" do
    subject { described_class.new(user).default_avatar_url }

    it { is_expected.to eq("//#{user.organization.host}:#{Capybara.server_port}#{ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")}") }
  end

  describe "#user_avatar_url" do
    subject { described_class.new(user).avatar_url }

    let(:avatar_image) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.asset("city.jpeg")),
        filename: "city.jpeg",
        content_type: "image/jpeg"
      )
    end

    before do
      user.avatar.attach(avatar_image)
    end

    it "is a test" do
      expect(subject).to eq(described_class.new(user).default_avatar_url)
    end

    context "when public" do
      before do
        user.published_at = Time.current
      end

      it { is_expected.to eq("/rails/active_storage/blobs/redirect/#{avatar_image.signed_id}/city.jpeg") }
    end
  end

  describe "#profile_path" do
    subject { described_class.new(user).profile_path }

    context "when user is deleted" do
      let(:user) { build(:user, :deleted) }

      it { is_expected.to eq("") }
    end

    context "when user is private" do
      it { is_expected.to eq("") }
    end

    context "when user is anonymous" do
      before do
        user.anonymity = true
      end

      it { is_expected.to eq("") }
    end

    context "when public account" do
      before do
        user.published_at = Time.current
      end

      it { is_expected.to eq("/profiles/#{user.nickname}") }
    end
  end
end

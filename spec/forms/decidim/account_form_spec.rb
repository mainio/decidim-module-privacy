# frozen_string_literal: true

require "spec_helper"

describe Decidim::AccountForm do
  subject do
    described_class.new(
      name:,
      email:,
      nickname:,
      old_password:,
      password:,
      password_confirmation:,
      avatar:,
      remove_avatar:,
      personal_url:,
      about:,
      locale: "es"
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end

  let(:user) { create(:user, password: user_password) }
  let(:user_password) { "decidim1234567890" }
  let(:old_password) { user_password }
  let(:organization) { user.organization }

  let(:name) { "Lord of the Foo" }
  let(:email) { "depths@ofthe.bar" }
  let(:nickname) { "foo_bar" }
  let(:password) { "Rf9kWTqQfyqkwseH" }
  let(:password_confirmation) { password }
  let(:avatar) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }
  let(:remove_avatar) { false }
  let(:personal_url) { "http://example.org" }
  let(:about) { "This is a description about me" }

  context "with correct data" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  describe "email" do
    context "when it's already in use in the same organization" do
      context "and belongs to a private user" do
        let!(:existing_user) { create(:user, email:, organization:) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "and belongs to a public user" do
        let!(:existing_user) { create(:user, email:, organization:, published_at: Time.current) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "and belongs to a group" do
        let!(:existing_group) { create(:user_group, email:, organization:) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "when it's already in use in another organization" do
      let!(:existing_user) { create(:user, email:) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end

  describe "nickname" do
    context "when it's already in use in the same organization" do
      context "and belongs to a private user" do
        let!(:existing_user) { create(:user, nickname:, organization:) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "and belongs to a public user" do
        let!(:existing_user) { create(:user, nickname:, organization:, published_at: Time.current) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "and belongs to a group" do
        let!(:existing_group) { create(:user_group, nickname:, organization:) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end

  describe "validate_old_password" do
    context "when email changed" do
      let(:password) { "" }
      let(:email) { "foo@example.org" }

      context "with correct old_password" do
        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "with incorrect old_password" do
        let(:old_password) { "foobar1234567890" }

        it { is_expected.not_to be_valid }
      end
    end

    context "when password present" do
      let(:email) { user.email }

      context "with correct old_password" do
        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "with incorrect old_password" do
        let(:old_password) { "foobar1234567890" }

        it { is_expected.not_to be_valid }
      end
    end
  end
end

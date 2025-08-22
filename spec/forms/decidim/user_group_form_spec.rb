# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroupForm do
  subject do
    described_class.new(
      name:,
      email:,
      nickname:,
      phone:,
      document_number:,
      avatar:,
      about:
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end

  let(:user) { create(:user) }
  let(:organization) { user.organization }

  let(:name) { "Lord of the Foo" }
  let(:email) { "depths@ofthe.bar" }
  let(:nickname) { "foo_bar" }
  let(:phone) { "987654321" }
  let(:document_number) { "12345678X" }
  let(:avatar) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }
  let(:about) { "This is a description about me" }

  context "with correct data" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  describe "nickname" do
    context "with an empty nickname" do
      let(:nickname) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when it's already in use in the same organization" do
      context "when private user" do
        let!(:existing_user) { create(:user, nickname:, organization:) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when anonymous user", :anonymity do
        let!(:existing_user) { create(:user, :anonymous, nickname:, organization:) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when public user" do
        let!(:existing_user) { create(:user, nickname:, organization:, published_at: Time.current) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "when it's already in use in another organization" do
      let!(:existing_user) { create(:user, nickname:) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end

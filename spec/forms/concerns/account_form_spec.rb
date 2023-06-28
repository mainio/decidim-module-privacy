# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AccountForm do
    subject do
      described_class.new(
        name: name,
        email: email,
        nickname: nickname,
        password: password,
        password_confirmation: password_confirmation,
        avatar: avatar,
        remove_avatar: remove_avatar,
        personal_url: personal_url,
        about: about,
        locale: "es"
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
          let!(:existing_user) { create(:user, email: email, organization: organization) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "and belongs to a public user" do
          let!(:existing_user) { create(:user, email: email, organization: organization, published_at: Time.current) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "and belongs to a group" do
          let!(:existing_group) { create(:user_group, email: email, organization: organization) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end

      context "when it's already in use in another organization" do
        let!(:existing_user) { create(:user, email: email) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end

    describe "nickname" do
      context "when it's already in use in the same organization" do
        context "and belongs to a private user" do
          let!(:existing_user) { create(:user, nickname: nickname, organization: organization) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "and belongs to a public user" do
          let!(:existing_user) { create(:user, nickname: nickname, organization: organization, published_at: Time.current) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "and belongs to a group" do
          let!(:existing_group) { create(:user_group, nickname: nickname, organization: organization) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end
    end
  end
end

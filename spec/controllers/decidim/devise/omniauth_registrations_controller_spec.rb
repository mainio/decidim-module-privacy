# frozen_string_literal: true

require "spec_helper"

describe Decidim::Devise::OmniauthRegistrationsController, type: :controller do
  routes { Decidim::Core::Engine.routes }

  let(:organization) { create(:organization) }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["devise.mapping"] = ::Devise.mappings[:user]
  end

  describe "POST create" do
    let(:provider) { "facebook" }
    let(:uid) { "12345" }
    let(:oauth_info) { { name: "Facebook User", nickname: "facebook_user", email: email } }
    let(:email) { "user@from-facebook.com" }

    before do
      request.env["omniauth.auth"] = {
        provider: provider,
        uid: uid,
        info: oauth_info
      }
    end

    context "with successful sign in" do
      before do
        post :create
      end

      it "logs in" do
        expect(controller).to be_user_signed_in
      end

      it "redirects to the authorizations path" do
        expect(subject).to redirect_to("/authorizations")
      end

      it "creates a new user" do
        expect(Decidim::User.entire_collection.count).to eq(1)
      end

      it "anonymizes the user's nickname" do
        user = Decidim::User.entire_collection.order(:id).last
        expect(user.nickname).to eq("u_#{user.id}")
      end
    end

    context "when someone else has reserved the automatically generated nickname" do
      let!(:another_user) { create(:user, :confirmed, organization: organization) }
      let(:next_user_id) { another_user.id + 1 }

      before do
        another_user.update!(nickname: "u_#{next_user_id}")

        post :create
      end

      it "logs in" do
        expect(controller).to be_user_signed_in
      end

      it "redirects to the authorizations path" do
        expect(subject).to redirect_to("/authorizations")
      end

      it "creates a new user" do
        expect(Decidim::User.entire_collection.count).to eq(2)
      end

      it "anonymizes the user's nickname" do
        user = Decidim::User.entire_collection.order(:id).last
        expect(user.nickname).to eq("u_#{user.id}_2")
      end
    end

    context "when nickname is not forwarded and a user with matching nickname already exists" do
      let(:oauth_info) { { name: "Facebook User", email: email } }
      let!(:another_user) { create(:user, organization: organization, nickname: "facebook_user") }

      before do
        post :create
      end

      it "logs in" do
        expect(controller).to be_user_signed_in
      end

      it "redirects to the authorizations path" do
        expect(subject).to redirect_to("/authorizations")
      end

      it "creates a new user" do
        expect(Decidim::User.entire_collection.count).to eq(2)
      end

      it "anonymizes the user's nickname" do
        user = Decidim::User.entire_collection.order(:id).last
        expect(user.nickname).to eq("u_#{user.id}")
      end
    end

    context "when the unverified email address is already in use" do
      let!(:user) { create(:user, organization: organization, email: email) }

      before do
        post :create
      end

      it "doesn't create a new user" do
        expect(Decidim::User.entire_collection.count).to eq(1)
      end

      it "logs in" do
        expect(controller).to be_user_signed_in
      end
    end
  end
end

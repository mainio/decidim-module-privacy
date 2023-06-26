# frozen_string_literal: true

require "spec_helper"

describe Decidim::CreateOmniauthRegistration do
  include Decidim::Privacy::CreateOmniauthRegistrationExtensions

  describe "#call" do
    let(:organization) { create(:organization) }
    let(:email) { "user@from-facebook.com" }
    let(:provider) { "facebook" }
    let(:uid) { "12345" }
    let(:oauth_signature) { Decidim::OmniauthRegistrationForm.create_signature(provider, uid) }
    let(:verified_email) { email }
    let(:form_params) do
      {
        "user" => {
          "provider" => provider,
          "uid" => uid,
          "email" => email,
          "email_verified" => true,
          "name" => "Facebook User",
          "nickname" => "facebook_user",
          "oauth_signature" => oauth_signature,
          "avatar_url" => "http://www.example.com/foo.jpg"
        }
      }
    end
    let(:form) do
      Decidim::OmniauthRegistrationForm.from_params(
        form_params
      ).with_context(
        current_organization: organization
      )
    end
    let(:command) { described_class.new(form, verified_email) }

    before do
      stub_request(:get, "http://www.example.com/foo.jpg")
        .to_return(status: 200, body: File.read("spec/assets/avatar.jpg"), headers: { "Content-Type" => "image/jpeg" })
    end

    context "when the form is valid" do
      it "creates a new user with an ananymized nickname" do
        allow(SecureRandom).to receive(:hex).and_return("decidim123456789")

        expect do
          command.call
        end.to change(Decidim::User.unscoped, :count).by(1)

        user = Decidim::User.unscoped.find_by(email: form.email)
        expect(user.encrypted_password).not_to be_nil
        expect(user.email).to eq(form.email)
        expect(user.organization).to eq(organization)
        expect(user.newsletter_notifications_at).to be_nil
        expect(user).to be_confirmed
        expect(user.valid_password?("decidim123456789")).to be(true)
        expect(user.nickname).to eq("u_#{user.id}")
      end
    end
  end
end

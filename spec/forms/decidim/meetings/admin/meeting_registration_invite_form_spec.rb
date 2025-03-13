# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingRegistrationInviteForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create :organization }
  let(:context) do
    {
      current_organization: organization
    }
  end

  let(:name) { "Foo" }
  let(:email) { "foo@example.org" }
  let(:existing_user) { true }
  let(:user_id) { nil }
  let(:attributes) do
    {
      name: name,
      email: email,
      existing_user: existing_user,
      user_id: user_id
    }
  end

  context "when existing user is present" do
    context "and no user is provided" do
      it { is_expected.to be_invalid }
    end

    context "and a private user exists" do
      let(:user_id) { create(:user, organization: organization).id }

      it { is_expected.to be_valid }
    end

    context "and an anonymous user exists", :anonymity do
      let(:user_id) { create(:user, :anonymous, organization: organization).id }

      it { is_expected.to be_valid }
    end

    context "and a public user exists" do
      let(:user_id) { create(:user, organization: organization, published_at: Time.current).id }

      it { is_expected.to be_valid }
    end
  end
end

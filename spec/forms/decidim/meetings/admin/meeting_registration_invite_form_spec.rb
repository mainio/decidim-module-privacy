# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingRegistrationInviteForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
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
      name:,
      email:,
      existing_user:,
      user_id:
    }
  end

  context "when existing user is present" do
    context "and no user is provided" do
      it { is_expected.not_to be_valid }
    end

    context "and a private user exists" do
      let(:user_id) { create(:user, organization:).id }

      it { is_expected.to be_valid }
    end

    context "and an anonymous user exists", :anonymity do
      let(:user_id) { create(:user, :anonymous, organization:).id }

      it { is_expected.to be_valid }
    end

    context "and a public user exists" do
      let(:user_id) { create(:user, organization:, published_at: Time.current).id }

      it { is_expected.to be_valid }
    end
  end
end

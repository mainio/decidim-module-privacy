# frozen_string_literal: true

require "spec_helper"
require "decidim/conferences/test/factories"

describe Decidim::Conferences::Admin::ConferenceSpeakerForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:conference) { create(:conference, organization:) }
  let(:current_participatory_space) { conference }
  let(:meeting_component) do
    create(:component, manifest_name: :meetings, participatory_space: conference)
  end

  let(:meetings) do
    create_list(
      :meeting,
      3,
      component: meeting_component
    )
  end

  let(:conference_meetings) do
    meetings.each do |meeting|
      meeting.becomes(Decidim::ConferenceMeeting)
    end
  end

  let(:conference_meeting_ids) { conference_meetings.map(&:id) }

  let(:context) do
    {
      current_participatory_space: conference,
      current_organization: organization
    }
  end

  let(:full_name) { "Full name" }
  let(:position) { Decidim::Faker::Localized.word }
  let(:affiliation) { Decidim::Faker::Localized.word }
  let(:short_bio) { Decidim::Faker::Localized.sentence }
  let(:twitter_handle) { "full_name" }
  let(:personal_url) { "http://decidim.org" }
  let(:avatar) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
  let(:existing_user) { false }
  let(:user_id) { nil }
  let(:attributes) do
    {
      "conference_speaker" => {
        "full_name" => full_name,
        "position" => position,
        "affiliation" => affiliation,
        "short_bio" => short_bio,
        "twitter_handle" => twitter_handle,
        "personal_url" => personal_url,
        "avatar" => avatar,
        "existing_user" => existing_user,
        "user_id" => user_id,
        "conference_meeting_ids" => conference_meeting_ids
      }
    }
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when existing user is present" do
    let(:existing_user) { true }

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

  describe "user" do
    subject { form.user }

    context "when a private user exists" do
      let(:user_id) { create(:user, organization:).id }

      it { is_expected.to be_a(Decidim::User) }
    end

    context "when an anonymous user exists", :anonymity do
      let(:user_id) { create(:user, :anonymous, organization:).id }

      it { is_expected.to be_a(Decidim::User) }
    end

    context "when a public user exists" do
      let(:user_id) { create(:user, organization:, published_at: Time.current).id }

      it { is_expected.to be_a(Decidim::User) }
    end
  end
end

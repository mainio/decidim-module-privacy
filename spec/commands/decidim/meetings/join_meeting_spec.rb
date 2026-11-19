# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::JoinMeeting do
  subject { command.call }

  let(:command) { described_class.new(meeting, user, registration_form) }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:component, manifest_name: :meetings, participatory_space:) }
  let(:meeting) do
    create(
      :meeting,
      component:,
      registrations_enabled: true,
      available_slots: 10,
      questionnaire: nil
    )
  end
  let(:registration_form) { Decidim::Meetings::JoinMeetingForm.new }
  let(:user) { create(:user, :confirmed, organization:) }

  shared_examples_for "meeting gamification scoring" do
    let(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }
    let(:user_badges_url) do
      url_helpers.profile_badges_url(
        nickname: user.nickname,
        host: organization.host
      )
    end

    it "increments the attended meetings score" do
      expect { subject }.to change {
        Decidim::Gamification.status_for(user, :attended_meetings).score
      }.from(0).to(1)
    end

    it "sends the badge notification" do
      perform_enqueued_jobs { subject }

      expect(last_email.subject).to eq("You have earned a new badge: Attended meetings!")
      expect(last_email_body).to include(user_badges_url)
    end
  end

  it_behaves_like "meeting gamification scoring"

  context "when the user is anonymous", :anonymity do
    let(:user) { create(:user, :confirmed, :anonymous, organization:) }

    it_behaves_like "meeting gamification scoring"
  end
end

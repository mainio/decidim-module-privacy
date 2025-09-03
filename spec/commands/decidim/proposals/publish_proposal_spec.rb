# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::PublishProposal do
  subject { command.call }

  let(:command) { described_class.new(proposal_draft, current_user) }

  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, organization:) }
  let(:follower) { create(:user, organization:) }
  let(:proposal_draft) { create(:proposal, :draft, component:, users: [current_user]) }
  let!(:follow) { create(:follow, followable: current_user, user: follower) }

  shared_examples_for "proposal gamification scoring" do
    let(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }
    let(:user_badges_url) do
      url_helpers.profile_badges_url(
        nickname: current_user.nickname,
        host: organization.host
      )
    end

    it "increments the proposals score" do
      expect { subject }.to change {
        Decidim::Gamification.status_for(current_user, :proposals).score
      }.by(1)
    end

    it "sends the badge notification" do
      perform_enqueued_jobs { subject }

      expect(last_email.subject).to eq("You have earned a new badge: Proposals!")
      expect(last_email_body).to include(user_badges_url)
    end
  end

  it_behaves_like "proposal gamification scoring"

  context "when the user is anonymous", :anonymity do
    let(:current_user) { create(:user, :anonymous, organization:) }

    it_behaves_like "proposal gamification scoring"
  end
end

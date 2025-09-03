# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::NotifyProposalAnswer do
  subject { command.call }

  let(:command) { described_class.new(proposal, initial_state) }
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:proposal) { create(:proposal, :accepted, component:, users: [creator_author]) }
  let(:creator_author) { create(:user, organization:) }
  let(:initial_state) { nil }
  let(:follow) { create(:follow, followable: proposal, user: follower) }
  let(:follower) { create(:user, organization:) }

  shared_examples_for "proposal gamification scoring" do
    let(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }
    let(:user_badges_url) do
      url_helpers.profile_badges_url(
        nickname: creator_author.nickname,
        host: organization.host
      )
    end

    it "increments the accepted proposals score" do
      follow

      # give proposal author initial points to avoid unwanted events during tests
      Decidim::Gamification.increment_score(creator_author, :accepted_proposals)

      expect { subject }.to change {
        Decidim::Gamification.status_for(creator_author, :accepted_proposals).score
      }.by(1)
    end

    it "sends the badge notification" do
      perform_enqueued_jobs { subject }

      badge_email = emails[1]
      expect(badge_email.subject).to eq("You have earned a new badge: Accepted proposals!")
      expect(email_body(badge_email)).to include(user_badges_url)
    end
  end

  it_behaves_like "proposal gamification scoring"

  context "when the user is anonymous", :anonymity do
    let(:creator_author) { create(:user, :anonymous, organization:) }

    it_behaves_like "proposal gamification scoring"
  end
end

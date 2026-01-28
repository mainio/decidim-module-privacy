# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::VoteProposal do
  subject { command.call }

  let(:command) { described_class.new(proposal, current_user) }
  let(:proposal) { create(:proposal) }
  let(:current_user) { create(:user, :confirmed, organization: proposal.organization) }

  shared_examples_for "proposal vote gamification scoring" do
    let(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }
    let(:user_badges_url) do
      url_helpers.profile_badges_url(
        nickname: current_user.nickname,
        host: current_user.organization.host
      )
    end

    it "increments the proposal votes score" do
      expect { subject }.to change {
        Decidim::Gamification.status_for(current_user, :proposal_votes).score
      }.by(1)
    end

    it "sends the badge notification" do
      # The threshold for the first badge is 5 votes, so increment the score by
      # 4 votes before running the badge creation command.
      Decidim::Gamification.increment_score(current_user, :proposal_votes, 4)

      perform_enqueued_jobs { subject }

      expect(last_email.subject).to eq("You have earned a new badge: Proposal votes!")
      expect(last_email_body).to include(user_badges_url)
    end
  end

  it_behaves_like "proposal vote gamification scoring"

  context "when the user is anonymous", :anonymity do
    let(:current_user) { create(:user, :confirmed, :anonymous, organization: proposal.organization) }

    it_behaves_like "proposal vote gamification scoring"
  end
end

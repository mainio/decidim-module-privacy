# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalVote do
  subject { proposal.proposal_votes_count }

  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, organization:, manifest_name: "proposals") }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:author) { create(:user, organization:) }
  let!(:user) { create(:user, :published, organization:) }
  let!(:proposal) { create(:proposal, component:, users: [author, user]) }
  let!(:first_proposal_vote) { create(:proposal_vote, proposal:, author:) }
  let!(:second_proposal_vote) { create(:proposal_vote, proposal:, author: user) }

  context "when proposal is voted by private and public user" do
    it "adds both votes to the count" do
      expect(subject).to eq(2)
    end
  end
end

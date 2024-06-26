# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalPresenter, type: :helper do
  let(:component) { create(:proposal_component) }
  let(:proposal) { create(:proposal, component:, users: [author]) }
  let(:author) { create(:user, :confirmed, organization: component.organization) }
  let(:presenter) { described_class.new(proposal) }

  describe "#author" do
    subject { presenter.author }

    context "when the author is private (default)" do
      it { is_expected.to be_nil }
    end
  end
end

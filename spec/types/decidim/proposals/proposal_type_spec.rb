# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/coauthorable_interface_examples"

describe Decidim::Proposals::ProposalType, type: :graphql do
  include_context "with a graphql class type"
  let(:component) { create(:proposal_component) }
  let(:model) { create(:proposal, :with_votes, :with_endorsements, :with_amendments, component:, users: [creator], user_groups: [user_group].compact) }
  let(:creator) { create(:user, :confirmed, :published, organization: component.organization) }
  let(:user_group) { nil }

  include_examples "coauthorable interface"

  context "with a private author" do
    let(:creator) { create(:user, :confirmed, organization: component.organization) }

    let(:query) { "{ author { name } }" }

    it "returns the user's name as the author name" do
      expect(response["author"]).to be_nil
    end
  end
end

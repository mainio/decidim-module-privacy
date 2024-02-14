# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    class ProposalsController
      include ::Decidim::Privacy::PrivacyActionsExtensions
    end
  end
end

describe Decidim::Proposals::ProposalsController, type: :controller do
  routes { Decidim::Proposals::Engine.routes }

  let!(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }

  let(:proposal_params) do
    {
      component_id: component.id
    }
  end
  let(:params) { { proposal: proposal_params } }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
  end

  it_behaves_like "permittable create actions"
  it_behaves_like "permittable new actions"

  context "when updating" do
    let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }
    let!(:proposal) { create(:proposal, component: component, users: [user]) }
    let(:proposal_params) do
      {
        title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
        body: "Ut sed dolor vitae purus volutpat venenatis. Donec sit amet sagittis sapien. Curabitur rhoncus ullamcorper feugiat. Aliquam et magna metus."
      }
    end
    let(:params) do
      {
        id: proposal.id,
        proposal: proposal_params
      }
    end

    it_behaves_like "permittable update actions"
    it_behaves_like "permittable edit actions"
  end
end

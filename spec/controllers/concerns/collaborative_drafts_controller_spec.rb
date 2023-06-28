# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    # class CollaborativeDraftsController < Decidim::Proposals::ApplicationController
    #   include ::Decidim::Privacy::PrivacyActionsExtensions
    # end
    describe CollaborativeDraftsController do
      routes { Decidim::Proposals::Engine.routes }

      let(:component) { create(:proposal_component, :with_creation_enabled, :with_collaborative_drafts_enabled) }
      let(:params) { { component_id: component.id } }
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:collaborative_draft) { create(:collaborative_draft, component: component, users: [user]) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      it_behaves_like "permittable create actions"
      it_behaves_like "permittable new actions"

      describe "#update" do
        let(:params) do
          {
            component_id: component.id,
            id: collaborative_draft.id,
            collaborative_draft: {
              title: ::Faker::Lorem.sentence,
              body: ::Faker::Lorem.sentence(word_count: 2)
            }
          }
        end

        it_behaves_like "permittable update actions"
      end

      describe "#edit" do
        let(:params) do
          { id: collaborative_draft.id }
        end

        it_behaves_like "permittable edit actions"
      end
    end
  end
end

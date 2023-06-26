# frozen_string_literal: true

require "spec_helper"

module Decidim
  class OwnUserGroupsController < ApplicationController
    include ::Decidim::Privacy::OwnUserGroupsControllerExtensions
  end
  describe OwnUserGroupsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let!(:organization) { create(:organization) }
    let!(:current_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:private_user_group) { create(:user_group, decidim_organization_id: organization.id, users: [current_user]) }
    let!(:user_group) { create(:user_group, decidim_organization_id: organization.id, users: [current_user], published_at: Time.current) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in current_user
    end

    describe "#index" do
      before do
        allow(organization).to receive(:user_groups_enabled?).and_return(true)
      end

      it "finds entire collection" do
        get :index
        expect(assigns(:user_groups)).to include(user_group)
        expect(assigns(:user_groups)).to include(private_user_group)
      end
    end
  end
end

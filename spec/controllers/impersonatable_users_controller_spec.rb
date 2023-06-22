# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    class ImpersonatableUsersController < Decidim::Admin::ApplicationController
      include ::Decidim::Privacy::ImpersonatableUsersControllerExtensions
    end
    describe ImpersonatableUsersController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:private_user) { create(:user, organization: organization) }
      let(:public_user) { create(:user, organization: organization, published_at: Time.current) }
      let(:another_admin) { create(:user, :admin, :confirmed, organization: organization) }

      describe "#index" do
        before do
          request.env["decidim.current_organization"] = organization
          sign_in admin_user
        end

        it "collects only non-admin public users" do
          get :index
          expect(assigns(:collection)).to eq([public_user])
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserActivitiesController do
  routes { Decidim::Core::Engine.routes }

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, nickname: "Nick", organization:, published_at: Time.current) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "#show" do
    context "when user is private" do
      let!(:user) { create(:user, nickname: "Nick", organization:) }

      it "renders private view" do
        expect do
          get :index, params: { nickname: "NICK" }
        end.to raise_error(ActionController::RoutingError, "Missing user: NICK")
      end
    end

    context "with an unknown user" do
      it "raises an ActionController::RoutingError" do
        expect do
          get :index, params: { nickname: "foobar" }
        end.to raise_error(ActionController::RoutingError, "Missing user: foobar")
      end
    end

    context "with an user with uppercase" do
      it "returns the lowercased user" do
        get :index, params: { nickname: "NICK" }
        expect(response).to render_template(:index)
      end
    end
  end
end

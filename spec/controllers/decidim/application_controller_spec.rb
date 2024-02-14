# frozen_string_literal: true

require "spec_helper"

module Decidim
  class ApplicationController < ::DecidimController
    include ::Decidim::Privacy::ApplicationControllerExtensions
  end
end

describe Decidim::ApplicationController, type: :controller do
  let!(:organization) { create :organization }
  let!(:user) { create :user, :confirmed, organization: organization }

  controller Decidim::ApplicationController do
    def show
      render plain: "Hello World"
    end
  end

  before do
    request.env["decidim.current_organization"] = organization
    routes.draw do
      get "show" => "decidim/application#show"
    end
  end

  context "when not signed in" do
    it "does does not add publish_account_modal to snippets" do
      get :show

      expect(snippets_instance).to include(%(<script src="#{asset_path("decidim_account_publish_handler.js")}" defer="defer"></script>))
      expect(snippets_instance).not_to include(an_instance_of(Decidim::Privacy::PublishAccountModalCell))
    end
  end

  context "when private user signed in" do
    before do
      sign_in user
    end

    it "addes publish_account_modal to snippets to the snippets" do
      get :show

      expect(snippets_instance).to include(%(<script src="#{asset_path("decidim_account_publish_handler.js")}" defer="defer"></script>))
      expect(snippets_instance).to include(an_instance_of(Decidim::Privacy::PublishAccountModalCell))
    end
  end

  context "when public user signed in" do
    let!(:user) { create :user, :confirmed, :published, organization: organization }

    before do
      sign_in user
    end

    it "does does not add publish_account_modal to snippets" do
      get :show

      expect(assigns(:snippets).instance_variable_get(:@snippets)).to be_nil
    end
  end

  private

  def asset_path(asset)
    ::Webpacker.instance.manifest.lookup!(asset)
  end

  def snippets_instance
    assigns(:snippets).instance_variable_get(:@snippets)[:foot]
  end
end

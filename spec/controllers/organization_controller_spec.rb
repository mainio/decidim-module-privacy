# frozen_string_literal: true

require "spec_helper"
module Decidim
  module Admin
    class OrganizationController < Decidim::Admin::ApplicationController
      include ::Decidim::Privacy::AdminOrganizationControllerExtensions
    end

    describe OrganizationController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "GET users and user groups in json format" do
        let(:parsed_response) { JSON.parse(response.body).map(&:symbolize_keys) }

        context "when user is blocked" do
          let!(:user) { create(:user, :blocked, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }

          it "returns an empty json array" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to eq([])
          end
        end

        context "when user is managed" do
          let!(:user) { create(:user, :managed, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }

          it "returns an empty json array" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to eq([])
          end
        end

        context "when user is deleted" do
          let!(:user) { create(:user, :deleted, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }

          it "returns an empty json array" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to eq([])
          end
        end
      end

      describe "GET users in json format" do
        let!(:user) { create(:user, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }
        let!(:public_user) { create(:user, name: "Daisy Public", nickname: "daisy_p", organization: organization, published_at: Time.current) }
        let!(:other_organization_user) { create(:user, name: "Daisy Foo", nickname: "daisy_f", published_at: Time.current) }

        let(:parsed_response) { JSON.parse(response.body).map(&:symbolize_keys) }

        context "when searching by name" do
          it "returns the id, name and nickname for filtered users" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to include({ value: user.id, label: "#{user.name} (@#{user.nickname})" })
            expect(parsed_response).to include({ value: public_user.id, label: "#{public_user.name} (@#{public_user.nickname})" })
          end
        end

        context "when searching by nickname" do
          it "returns the id, name and nickname for filtered users" do
            get :users, format: :json, params: { term: "@daisy" }
            expect(parsed_response).to include({ value: user.id, label: "#{user.name} (@#{user.nickname})" })
            expect(parsed_response).to include({ value: public_user.id, label: "#{public_user.name} (@#{public_user.nickname})" })
          end
        end

        context "when searching by email" do
          it "returns the id, name and nickname for filtered users" do
            get :users, format: :json, params: { term: user.email }
            expect(parsed_response).to eq([{ value: user.id, label: "#{user.name} (@#{user.nickname})" }])
          end
        end

        context "when user is blocked" do
          let!(:user) { create(:user, :blocked, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }

          it "returns an empty json array" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to eq([{ value: public_user.id, label: "#{public_user.name} (@#{public_user.nickname})" }])
          end
        end

        context "when user is managed" do
          let!(:user) { create(:user, :managed, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }

          it "returns an empty json array" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).to eq([{ value: public_user.id, label: "#{public_user.name} (@#{public_user.nickname})" }])
          end
        end

        context "when user is deleted" do
          let!(:user) { create(:user, :deleted, name: "Daisy Miller", nickname: "daisy_m", organization: organization) }

          it "returns an empty json array" do
            get :users, format: :json, params: { term: "daisy" }
            expect(parsed_response).not_to include({ value: user.id, label: "#{user.name} (@#{user.nickname})" })
          end
        end
      end
    end
  end
end

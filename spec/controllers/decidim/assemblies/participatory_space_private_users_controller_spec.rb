# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    class ParticipatorySpacePrivateUsersController
      include ::Decidim::Privacy::ParticipatorySpacePrivateUsersControllerExtensions
    end
  end
end

describe Decidim::Assemblies::ParticipatorySpacePrivateUsersController do
  routes { Decidim::Assemblies::Engine.routes }

  let(:organization) { create(:organization) }

  let!(:assembly) do
    create(
      :assembly,
      :published,
      organization:
    )
  end

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "GET index" do
    context "when assembly has no members" do
      it "displays an empty array of members" do
        get :index, params: { assembly_slug: assembly.slug }
        expect(controller.helpers.collection).to be_empty
      end
    end

    context "when there are members" do
      let!(:first_member) { create(:assembly_private_user, user: first_user, privatable_to: assembly, published: true) }
      let!(:second_member) { create(:assembly_private_user, user: second_user, privatable_to: assembly, published: true) }
      let!(:non_member) { create(:assembly_private_user, published: true) }

      context "when assembly has no public members" do
        let(:first_user) { create(:user, :confirmed, organization:) }
        let(:second_user) { create(:user, :confirmed, organization:) }

        it "displays an empty array of members" do
          get :index, params: { assembly_slug: assembly.slug }

          expect(controller.helpers.collection).to be_empty
        end
      end

      context "when assembly has some public members" do
        let(:first_user) { create(:user, :published, :confirmed, organization:) }
        let(:second_user) { create(:user, :confirmed, organization:) }

        context "when user has permissions" do
          it "displays only public members" do
            get :index, params: { assembly_slug: assembly.slug }

            expect(controller.helpers.collection).to contain_exactly(first_member)
          end
        end
      end

      context "when assembly has some anonymous members", :anonymity do
        let(:first_user) { create(:user, :anonymous, :confirmed, organization:) }
        let(:second_user) { create(:user, :confirmed, organization:) }

        it "displays an empty array of members" do
          get :index, params: { assembly_slug: assembly.slug }

          expect(controller.helpers.collection).to be_empty
        end
      end
    end
  end
end

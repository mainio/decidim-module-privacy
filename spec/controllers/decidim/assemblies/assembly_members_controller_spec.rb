# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    class AssemblyMembersController
      include ::Decidim::Privacy::AssemblyMembersControllerExtensions
    end
  end
end

describe Decidim::Assemblies::AssemblyMembersController do
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
      let!(:first_member) { create(:assembly_member, :with_user, assembly:) }
      let!(:second_member) { create(:assembly_member, assembly:) }
      let!(:non_member) { create(:assembly_member) }

      context "when assembly has no public members" do
        it "displays an empty array of members" do
          get :index, params: { assembly_slug: assembly.slug }

          expect(controller.helpers.collection).to be_empty
        end
      end

      context "when assembly has some public members" do
        before do
          first_member.user.update!(published_at: Time.current)
        end

        context "when user has permissions" do
          it "displays only public members" do
            get :index, params: { assembly_slug: assembly.slug }

            expect(controller.helpers.collection).to contain_exactly(first_member)
          end
        end
      end
    end
  end
end

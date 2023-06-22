# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    class AssemblyMembersController
      include ::Decidim::Privacy::AssemblyMembersControllerExtensions
    end
    describe AssemblyMembersController, type: :controller do
      routes { Decidim::Assemblies::Engine.routes }

      let(:organization) { create(:organization) }

      let!(:assembly) do
        create(
          :assembly,
          :published,
          organization: organization
        )
      end

      before do
        request.env["decidim.current_organization"] = organization
      end

      describe "GET index" do
        context "when assembly has no members" do
          it "redirects to 404" do
            expect { get :index, params: { assembly_slug: assembly.slug } }
              .to raise_error(ActionController::RoutingError)
          end
        end

        context "when there are members" do
          let!(:member1) { create(:assembly_member, :with_user, assembly: assembly) }
          let!(:member2) { create(:assembly_member, assembly: assembly) }
          let!(:non_member) { create(:assembly_member) }

          context "when assembly has no public members" do
            it "redirects to 404" do
              expect { get :index, params: { assembly_slug: assembly.slug } }
                .to raise_error(ActionController::RoutingError)
            end
          end

          context "when assembly has some public members" do
            before do
              member1.user.update!(published_at: Time.current)
            end

            context "when user has permissions" do
              it "displays only public members" do
                get :index, params: { assembly_slug: assembly.slug }

                expect(controller.helpers.collection).to match_array([member1])
              end
            end
          end
        end
      end
    end
  end
end

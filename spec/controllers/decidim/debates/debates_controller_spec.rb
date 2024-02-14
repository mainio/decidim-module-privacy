# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::DebatesController, type: :controller do
  routes { Decidim::Debates::Engine.routes }

  let(:organization) { create(:organization) }
  let(:component) { create(:debates_component, :with_creation_enabled, organization: organization) }
  let!(:debate) { create(:debate, component: component, author: user) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:params) { { component_id: component.id } }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
  end

  it_behaves_like "permittable create actions"
  it_behaves_like "permittable new actions"

  describe "#edit" do
    let(:params) do
      {
        id: debate.id,
        component_id: component.id,
        debate: {
          title: "Test debates creation1",
          description: "Test debates creation1 description"
        }
      }
    end

    it_behaves_like "permittable update actions"
    it_behaves_like "permittable edit actions"
  end
end

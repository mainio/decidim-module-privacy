# frozen_string_literal: true

require "spec_helper"

describe "Accountability", type: :system do
  include_context "with a component"

  let(:manifest_name) { "accountability" }

  describe "show" do
    let!(:result) { create(:result, component: component) }
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id) }

    context "when a result has linked proposals with private authors" do
      let(:proposals_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:proposal) { create(:proposal, :accepted, component: proposals_component, users: [proposal_author]) }
      let(:proposal_author) { create(:user, :confirmed, organization: organization) }

      before do
        result.link_resources([proposal], "included_proposals")
      end

      it "renders the linked proposals without the author" do
        visit path
        expect(page).to have_content(translated(result.title))
        page.scroll_to(find(".section-heading", text: "Proposals included in this result".upcase))

        expect(page).to have_css(".card--list__item", text: translated(proposal.title))
        expect(page).not_to have_css(".card--list__item .author")
      end
    end
  end
end

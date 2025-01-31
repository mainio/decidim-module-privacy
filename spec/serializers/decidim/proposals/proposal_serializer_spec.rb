# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalSerializer do
  subject do
    described_class.new(proposal)
  end

  let!(:body) { { en: Faker::Lorem.sentence } }
  let!(:proposal) { create(:proposal, :accepted, body:) }
  let(:participatory_process) { component.participatory_space }
  let(:component) { proposal.component }

  let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
  let(:meetings) { create_list(:meeting, 2, :published, component: meetings_component) }

  let!(:proposals_component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:other_proposals) { create_list(:proposal, 2, component: proposals_component) }

  let(:serialized) { subject.serialize }

  let(:expected_answer) do
    answer = proposal.answer
    Decidim.available_locales.each_with_object({}) do |locale, result|
      result[locale.to_s] = if answer.is_a?(Hash)
                              answer[locale.to_s] || ""
                            else
                              ""
                            end
    end
  end

  before do
    proposal.link_resources(meetings, "proposals_from_meeting")
    proposal.link_resources(other_proposals, "copied_from_component")
  end

  describe "#serialize" do
    let(:serialized) { subject.serialize }

    describe "author" do
      context "when it is a user" do
        let!(:user) { create(:user, :published, name: "John Doe", organization: component.organization) }
        let(:component) { create(:proposal_component) }
        let!(:proposal) { create(:proposal, component:, users: [user]) }

        it "serializes the user name" do
          expect(serialized[:author]).to include(name: ["John Doe"])
        end

        it "serializes the link to its profile" do
          expect(serialized[:author]).to include(url: [profile_url(proposal.creator_author.nickname)])
        end

        context "when author is deleted" do
          let!(:user) { create(:user, :published, :deleted, name: "", nickname: "", organization: component.organization) }
          let!(:proposal) { create(:proposal, component:, users: [user]) }

          it "serializes the user id" do
            expect(serialized[:author]).to include(id: [user.id])
          end

          it "serializes the user name" do
            expect(serialized[:author]).to include(name: [""])
          end

          it "serializes the link to its profile" do
            expect(serialized[:author]).to include(url: [""])
          end
        end
      end
    end
  end

  def profile_url(nickname)
    Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:)
  end

  def host
    proposal.organization.host
  end
end

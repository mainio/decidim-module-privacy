# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::InitiativeSerializer do
  subject do
    described_class.new(initiative)
  end

  let(:organization) { create(:organization) }
  let!(:author) { create(:user, :published, :confirmed, organization:) }
  let!(:initiative) { create(:initiative, organization:, author:) }

  describe "#serialize" do
    let(:serialized) { subject.serialize }

    context "when there's a private user in data" do
      it "hides author's information" do
        author.update(published_at: nil)
        expect(serialized[:authors]).to include(id: [0], name: ["Unnamed participant"])
      end
    end

    context "when there's an anonymous user in data", :anonymity do
      it "hides author's information" do
        author.update(published_at: nil, anonymity: true)
        expect(serialized[:authors]).to include(id: [0], name: ["Unnamed participant"])
      end
    end

    context "when there's a public user in data" do
      it "shows author's information" do
        expect(serialized[:authors]).to include(id: [author.id], name: [author.name])
      end
    end
  end
end

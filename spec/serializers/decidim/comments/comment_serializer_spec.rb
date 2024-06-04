# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentSerializer do
  subject do
    described_class.new(comment)
  end

  let!(:commentable) { create(:dummy_resource) }
  let!(:author) { create(:user, :published, organization: commentable.organization) }
  let!(:comment) { create(:comment, commentable:, author:) }

  describe "#serialize" do
    let(:serialized) { subject.serialize }

    context "when there's a private user in data" do
      it "hides author's information" do
        author.update(published_at: nil)
        expect(serialized[:author]).to include(id: 0, name: "Anonymous")
      end
    end

    context "when there's a public user in data" do
      it "shows author's information" do
        expect(serialized[:author]).to include(id: author.id, name: author.name)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Comments::CommentType do
  include_context "with a graphql class type"

  let(:model) { create(:comment, commentable: commentable, author: author, user_group: user_group) }
  let(:commentable) { create(:dummy_resource) }
  let(:author) { create(:user, :confirmed, :published, organization: commentable.organization) }
  let(:user_group) { nil }

  describe "author" do
    let(:query) { "{ author { name } }" }

    context "when the author is public" do
      it "returns the user's name" do
        expect(response).to include("author" => { "name" => author.name })
      end
    end

    context "when the author is private" do
      before do
        # This can happen if the user commented and later made their profile
        # private. Note that the comment creation fails if we try to create it
        # with a private author which is why we first create the comment and
        # then set the user private.
        model
        author.update!(published_at: nil)
      end

      it "returns anonymous user" do
        expect(response).to include("author" => { "name" => "Anonymous" })
      end
    end
  end
end

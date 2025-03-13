# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Comment do
  let!(:commentable) { create(:dummy_resource) }
  let!(:author) { create(:user, :published, organization: commentable.organization) }
  let!(:comment) { create(:comment, commentable: commentable, author: author) }

  describe "#author" do
    subject { comment }

    context "when private" do
      before do
        author.update(published_at: nil)
      end

      it "returns privateuser instance" do
        expect(subject.author).to be_an_instance_of(::Decidim::Privacy::PrivateUser)
      end
    end

    context "when anonymous", :anonymity do
      before do
        author.update(anonymity: true, published_at: nil)
      end

      it "returns privateuser instance" do
        expect(subject.author).to be_an_instance_of(::Decidim::Privacy::PrivateUser)
      end
    end

    context "when public" do
      it "returns author" do
        expect(subject.author).to eq(author)
      end
    end
  end
end

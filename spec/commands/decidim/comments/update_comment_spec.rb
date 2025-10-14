# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::UpdateComment, :anonymity do
  subject { command.call }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:author) { create(:user, :anonymous, :admin, organization:) }
  let(:dummy_resource) { create(:dummy_resource, component:) }
  let(:commentable) { dummy_resource }
  let(:initial_body) { "Initial body" }
  let(:comment) { create(:comment, author:, commentable:, body: initial_body) }
  let(:body) { "This is a reasonable comment" }
  let(:form_params) do
    {
      "comment" => {
        "body" => body,
        "commentable" => commentable
      }
    }
  end
  let(:form) do
    Decidim::Comments::CommentForm.from_params(
      form_params
    ).with_context(
      current_organization: organization
    )
  end
  let(:current_user) { author }
  let(:command) { described_class.new(comment, current_user, form) }

  context "when author anonymous" do
    it "updates the comment" do
      expect(subject).to broadcast(:ok)
      expect(comment.body).to be_a(Hash)
      expect(comment.body["en"]).to eq body
    end
  end

  context "when author public" do
    let(:author) { create(:user, :published, organization:) }

    it "updates the comment" do
      expect(subject).to broadcast(:ok)
      expect(comment.body).to be_a(Hash)
      expect(comment.body["en"]).to eq body
    end
  end

  context "when author private" do
    let(:author) { create(:user, organization:) }

    it "doesn't update the comment" do
      expect(subject).to broadcast(:invalid)
      expect(comment.body["en"]).to eq("Initial body")
    end
  end
end

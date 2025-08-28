# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentsController do
  routes { Decidim::Comments::Engine.routes }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:commentable) { create(:dummy_resource, component:) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "POST create" do
    let(:user) { create(:user, :confirmed, locale: "en", organization:) }
    let(:comment) { Decidim::Comments::Comment.last }
    let(:params) do
      { comment: comment_params, xhr: true }
    end
    let(:comment_alignment) { 0 }
    let(:comment_params) do
      {
        commentable_gid: commentable.to_signed_global_id.to_s,
        body: "This is a new comment",
        alignment: comment_alignment
      }
    end

    context "when private user" do
      before do
        sign_in user
      end

      it "does not permit create action" do
        post(:create, xhr: true, params:)
        expect(response).to render_template("decidim/privacy/privacy_block")
      end
    end

    context "when anonymous user", :anonymity do
      before do
        user.update!(anonymity: true)
        sign_in user
      end

      it "permits create action" do
        post(:create, xhr: true, params:)
        expect(response).to have_http_status(:ok).or have_http_status(:no_content)
      end
    end

    context "when public user" do
      before do
        user.update!(published_at: Time.current)
        sign_in user
      end

      it "permits create action" do
        post(:create, xhr: true, params:)
        expect(response).to have_http_status(:ok).or have_http_status(:no_content)
      end
    end
  end
end

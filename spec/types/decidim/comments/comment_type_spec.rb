# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Comments::CommentType do
  include_context "with a graphql class type"

  let(:model) { create(:comment, commentable:, author:, user_group:) }
  let(:participatory_space) { create(:participatory_process) }
  let(:component) { create(:dummy_component, :published, participatory_space:) }
  let(:commentable) { create(:dummy_resource, :published, component:) }
  let(:author) { create(:user, :confirmed, :published, organization: commentable.organization) }
  let(:user_group) { nil }

  describe "author" do
    let(:query) { "{ id author { id name nickname avatarUrl profilePath badge organizationName } }" }

    context "when the author is public" do
      let(:avatar_url) { author.attached_uploader(:avatar).path(variant: :thumb) }

      it "returns the user's name" do
        expect(response["author"]).to include("name" => author.name)
      end

      it "returns the user's nickname" do
        expect(response["author"]).to include("nickname" => "@#{author.nickname}")
      end

      it "returns the user's avatar URL" do
        expect(response["author"]).to include("avatarUrl" => avatar_url)
      end

      it "returns the user's profile_path" do
        expect(response["author"]).to include("profilePath" => "/profiles/#{author.nickname}")
      end

      it "returns the user's badge" do
        expect(response["author"]).to include("badge" => "")
      end

      it "returns the user's organization name" do
        expect(response["author"]).to include("organizationName" => commentable.organization.name)
      end
    end

    context "when the author is private" do
      let(:avatar_url) { "//#{commentable.organization.host}:#{Capybara.server_port}#{ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")}" }

      before do
        # This can happen if the user commented and later made their profile
        # private. Note that the comment creation fails if we try to create it
        # with a private author which is why we first create the comment and
        # then set the user private.
        model
        author.update!(published_at: nil)
      end

      it "returns anonymous user" do
        expect(response["author"]).to include("name" => "Unnamed participant")
      end

      it "returns an empty nickname" do
        expect(response["author"]).to include("nickname" => "")
      end

      it "returns the default avatar URL" do
        expect(response["author"]).to include("avatarUrl" => avatar_url)
      end

      it "returns an empty profile_path" do
        expect(response["author"]).to include("profilePath" => "")
      end

      it "returns an empty badge" do
        expect(response["author"]).to include("badge" => "")
      end

      it "returns the user's organization name" do
        expect(response["author"]).to include("organizationName" => commentable.organization.name)
      end

      # This should not be possible through DB constraints but apparently not
      # all these constraints apply to all old data which may cause the
      # organization to fail to be fetched.
      context "and the original record does not return an author" do
        let(:query) { "{ author { organizationName } }" }

        let(:dummy_class) do
          parent = Class.new(Decidim::ApplicationRecord) do
            def self.name
              "FooBar"
            end

            def author
              nil
            end

            def user_group
              nil
            end

            def hidden?
              false
            end

            def deleted?
              false
            end
          end

          Class.new(parent) do
            self.table_name = "decidim_comments_comments"

            include Decidim::Privacy::ModelAuthorExtensions
          end
        end

        let(:comment) { create(:comment, commentable:, author:, user_group:) }
        let(:model) { dummy_class.find(comment.id) }

        it "returns an empty organization name" do
          expect(response["author"]).to include("organizationName" => "")
        end
      end
    end

    context "when the author is anonymous", :anonymity do
      let(:avatar_url) { "//#{commentable.organization.host}:#{Capybara.server_port}#{ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")}" }

      before do
        # This can happen if the user commented and later made their profile
        # private. Note that the comment creation fails if we try to create it
        # with a private author which is why we first create the comment and
        # then set the user private and anonymous.
        model
        author.update!(published_at: nil, anonymity: true)
      end

      it "returns anonymous user" do
        expect(response["author"]).to include("name" => "Unnamed participant")
      end

      it "returns an empty nickname" do
        expect(response["author"]).to include("nickname" => "")
      end

      it "returns the default avatar URL" do
        expect(response["author"]).to include("avatarUrl" => avatar_url)
      end

      it "returns an empty profile_path" do
        expect(response["author"]).to include("profilePath" => "")
      end

      it "returns an empty badge" do
        expect(response["author"]).to include("badge" => "")
      end

      it "returns the user's organization name" do
        expect(response["author"]).to include("organizationName" => commentable.organization.name)
      end

      # This should not be possible through DB constraints but apparently not
      # all these constraints apply to all old data which may cause the
      # organization to fail to be fetched.
      context "and the original record does not return an author" do
        let(:query) { "{ author { organizationName } }" }

        let(:dummy_class) do
          parent = Class.new(Decidim::ApplicationRecord) do
            def self.name
              "FooBar"
            end

            def author
              nil
            end

            def user_group
              nil
            end

            def hidden?
              false
            end

            def deleted?
              false
            end
          end

          Class.new(parent) do
            self.table_name = "decidim_comments_comments"

            include Decidim::Privacy::ModelAuthorExtensions
          end
        end

        let(:comment) { create(:comment, commentable:, author:, user_group:) }
        let(:model) { dummy_class.find(comment.id) }

        it "returns an empty organization name" do
          expect(response["author"]).to include("organizationName" => "")
        end
      end
    end
  end
end

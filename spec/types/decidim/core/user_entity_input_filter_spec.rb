# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

describe Decidim::Core::UserEntityInputFilter, type: :graphql do
  include_context "with a graphql class type"

  let(:type_class) { Decidim::Api::QueryType }

  let(:user) { create(:user, :confirmed, organization: current_organization) }
  let(:user_group) { create(:user_group, :confirmed, :verified, organization: current_organization) }
  let!(:models) { [user, user_group] }

  context "when user or groups are not confirmed" do
    let(:user) { create(:user, organization: current_organization) }
    let(:user_group) { create(:user_group, organization: current_organization) }
    let(:query) { %({ users { id } }) }

    it "returns all the types" do
      users = response["users"]
      expect(users).to eq([])
    end
  end

  context "when user or groups are deleted" do
    let(:user) { create(:user, :deleted, organization: current_organization) }
    let(:user_group) { create(:user_group, :confirmed, :verified, deleted_at: Time.current, organization: current_organization) }
    let(:query) { %({ users { id } }) }

    it "returns all the types" do
      users = response["users"]
      expect(users).to eq([])
    end
  end

  context "when user is published, and user group is verified" do
    let(:user) { create(:user, :confirmed, :published, organization: current_organization) }
    let(:user_group) { create(:user_group, :confirmed, :verified, organization: current_organization) }
    let(:query) { %({ users { id } }) }

    it "returns all the types" do
      users = response["users"]
      expect(users).to include("id" => user.id.to_s)
      expect(users).to include("id" => user_group.id.to_s)
    end

    context "when filtering by type User" do
      let(:query) { %[{ users(filter: { type: "user" }) { id } }] }

      it "returns the types requested" do
        users = response["users"]
        expect(users).to include("id" => user.id.to_s)
        expect(users).not_to include("id" => user_group.id.to_s)
      end

      context "when user is blocked" do
        let(:user) { create(:user, :blocked, :confirmed, organization: current_organization) }

        it "does not returns all the types" do
          users = response["users"]
          expect(users).to eq([])
        end
      end
    end

    context "when filtering by type UserGroup" do
      let(:query) { %[{ users(filter: { type: "group" }) { id } }] }

      it "returns the types requested" do
        users = response["users"]
        expect(users).to include("id" => user_group.id.to_s)
        expect(users).not_to include("id" => user.id.to_s)
      end
    end

    context "when search a user by nickname" do
      let!(:user1) { create(:user, :confirmed, :published, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }
      let!(:user2) { create(:user, nickname: "_foo_user_2", name: "FooBar User 2", organization: current_organization) }
      let!(:user3) { create(:user_group, :confirmed, :verified, nickname: "_bar_user_3", name: "FooBar User 3", organization: current_organization) }
      let!(:user4) { create(:user, :confirmed, :published, nickname: "_foo_user_4", name: "FooBar User 4") }
      let!(:user5) { create(:user, :confirmed, :published, nickname: "_foo_user_5", name: "FooBar User 5", organization: current_organization) }
      let!(:user6) { create(:user, :confirmed, :published, nickname: "_foo_user_6", name: "FooBar User 6", organization: current_organization) }
      let(:query) { %({ users(filter: { nickname: \"#{term}\" }) { name }}) }
      let(:term) { "foo_user" }

      it "returns matching users" do
        expect(response["users"]).to include("name" => user1.name)
        expect(response["users"]).not_to include("name" => user2.name)
        expect(response["users"]).not_to include("name" => user3.name)
        expect(response["users"]).not_to include("name" => user4.name)
        expect(response["users"]).to include("name" => user5.name)
        expect(response["users"]).to include("name" => user6.name)
      end

      context "when user is blocked" do
        let!(:user1) { create(:user, :blocked, :published, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => user1.name)
        end
      end

      context "when user is deleted" do
        let!(:user1) { create(:user, :deleted, :confirmed, :published, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => user1.name)
        end
      end

      context "when user is private" do
        let!(:user1) { create(:user, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => user1.name)
        end
      end

      context "when search a user by name" do
        let(:query) { %({ users(filter: { name: \"#{term}\" }) { name }}) }
        let(:term) { "FooBar User" }

        it "returns matching users" do
          expect(response["users"]).to include("name" => user1.name)
          expect(response["users"]).not_to include("name" => user2.name)
          expect(response["users"]).to include("name" => user3.name)
          expect(response["users"]).not_to include("name" => user4.name)
          expect(response["users"]).to include("name" => user5.name)
          expect(response["users"]).to include("name" => user6.name)
        end

        context "when user is blocked" do
          let!(:user1) { create(:user, :blocked, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

          it "does not returns matching users" do
            expect(response["users"]).not_to include("name" => user1.name)
          end
        end

        context "when user is private" do
          let!(:user1) { create(:user, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

          it "does not returns matching users" do
            expect(response["users"]).not_to include("name" => user1.name)
          end
        end
      end
    end
  end
end

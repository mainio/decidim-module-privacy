# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

describe Decidim::Core::UserEntityInputFilter, type: :graphql do
  include_context "with a graphql class type"

  let(:type_class) { Decidim::Api::QueryType }

  let(:user) { create(:user, :confirmed, organization: current_organization) }
  let!(:models) { [user] }

  context "when user is not confirmed" do
    let(:user) { create(:user, organization: current_organization) }
    let(:query) { %({ users { id } }) }

    it "returns all the types" do
      users = response["users"]
      expect(users).to eq([])
    end
  end

  context "when user is deleted" do
    let(:user) { create(:user, :deleted, organization: current_organization) }
    let(:query) { %({ users { id } }) }

    it "returns all the types" do
      users = response["users"]
      expect(users).to eq([])
    end
  end

  context "when user is published" do
    let(:user) { create(:user, :confirmed, :published, organization: current_organization) }
    let(:query) { %({ users { id } }) }

    it "returns users" do
      users = response["users"]
      expect(users).to include("id" => user.id.to_s)
    end

    context "when filtering by type User" do
      let(:query) { %[{ users(filter: { type: "user" }) { id } }] }

      it "returns the user type" do
        users = response["users"]
        expect(users).to include("id" => user.id.to_s)
      end

      context "when user is blocked" do
        let(:user) { create(:user, :blocked, :confirmed, organization: current_organization) }

        it "does not return user type" do
          users = response["users"]
          expect(users).to eq([])
        end
      end
    end

    context "when search a user by nickname" do
      let!(:first_user) { create(:user, :confirmed, :published, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }
      let!(:second_user) { create(:user, nickname: "_foo_user_2", name: "FooBar User 2", organization: current_organization) }
      let!(:third_user) { create(:user, :confirmed, :published, nickname: "_foo_user_4", name: "FooBar User 4") }
      let!(:fourth_user) { create(:user, :confirmed, :published, nickname: "_foo_user_5", name: "FooBar User 5", organization: current_organization) }
      let!(:fifth_user) { create(:user, :confirmed, :published, nickname: "_foo_user_6", name: "FooBar User 6", organization: current_organization) }
      let(:query) { %({ users(filter: { nickname: "#{term}" }) { name }}) }
      let(:term) { "foo_user" }

      it "returns matching users" do
        expect(response["users"]).to include("name" => first_user.name)
        expect(response["users"]).not_to include("name" => second_user.name)
        expect(response["users"]).not_to include("name" => third_user.name)
        expect(response["users"]).to include("name" => fourth_user.name)
        expect(response["users"]).to include("name" => fifth_user.name)
      end

      context "when user is blocked" do
        let!(:first_user) { create(:user, :blocked, :published, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => first_user.name)
        end
      end

      context "when user is deleted" do
        let!(:first_user) { create(:user, :deleted, :confirmed, :published, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => first_user.name)
        end
      end

      context "when user is private" do
        let!(:first_user) { create(:user, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => first_user.name)
        end
      end

      context "when search a user by name" do
        let(:query) { %({ users(filter: { name: "#{term}" }) { name }}) }
        let(:term) { "FooBar User" }

        it "returns matching users" do
          expect(response["users"]).to include("name" => first_user.name)
          expect(response["users"]).not_to include("name" => second_user.name)
          expect(response["users"]).not_to include("name" => third_user.name)
          expect(response["users"]).to include("name" => fourth_user.name)
          expect(response["users"]).to include("name" => fifth_user.name)
        end

        context "when user is blocked" do
          let!(:first_user) { create(:user, :blocked, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

          it "does not returns matching users" do
            expect(response["users"]).not_to include("name" => first_user.name)
          end
        end

        context "when user is private" do
          let!(:first_user) { create(:user, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

          it "does not returns matching users" do
            expect(response["users"]).not_to include("name" => first_user.name)
          end
        end
      end

      context "when user is anonymous", :anonymity do
        let!(:first_user) { create(:user, :anonymous, :confirmed, nickname: "_foo_user_1", name: "FooBar User 1", organization: current_organization) }

        it "does not returns matching users" do
          expect(response["users"]).not_to include("name" => first_user.name)
        end
      end
    end
  end
end

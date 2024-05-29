# frozen_string_literal: true

require "spec_helper"

shared_examples_for "coauthorable interface" do
  describe "author" do
    let(:author) { model.creator_author }

    describe "with a regular user" do
      let(:query) { "{ author { name } }" }

      context "with a private creator" do
        before do
          author.update(published_at: nil)
        end
        it "returns nil" do
          expect(response["author"]).to eq(nil)
        end
      end

      context "with a public creator" do
        it "returns nil" do
          expect(response["author"]["name"]).to eq(author.name)
        end
      end
    end

    describe "with a user group" do
      let(:user_group) { create(:user_group, :confirmed, :verified, organization: component.organization) }
      let(:query) { "{ author { name } }" }

      before do
        user_group.memberships.create!(user: creator, role: "member")

        coauthorship = model.coauthorships.first
        coauthorship.update!(user_group:)
      end

      it "includes returns the user group's name as the author name" do
        expect(response["author"]["name"]).to eq(user_group.name)
      end
    end

    describe "with a several coauthors" do
      let(:query) { "{ author { name } authors { name } authorsCount }" }
      let(:coauthor) { create(:user, :confirmed, :published, organization: model.participatory_space.organization) }

      before do
        model.add_coauthor coauthor
        model.save!
      end

      context "when both are public users" do
        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns an array of authors" do
          expect(response["authors"].count).to eq(2)
          expect(response["authors"]).to include("name" => author.name)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "returns a main author" do
          expect(response["author"]["name"]).to eq(author.name)
        end

        context "when main author is private" do
          before { creator.update(published_at: nil) }

          it "returns nil" do
            expect(response["author"]).to be_nil
          end
        end
      end

      context "when main author is deleted" do
        before { author.update(deleted_at: Time.current) }

        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns an array of authors" do
          expect(response["authors"].count).to eq(1)
          expect(response["authors"]).not_to include("name" => author.name)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "returns nil for the main author" do
          expect(response["author"]).to be_nil
        end
      end

      context "when author is the organization" do
        let(:model) { create(:proposal, :official, component:) }

        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns 1 author in authors array" do
          expect(response["authors"].count).to eq(1)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "does not return a main author" do
          expect(response["author"]).to eq(nil)
        end
      end

      context "when author is a meeting" do
        let(:model) { create(:proposal, :official_meeting, component:) }

        it "returns 2 total co-authors" do
          expect(response["authorsCount"]).to eq(2)
        end

        it "returns 1 author in authors array" do
          expect(response["authors"].count).to eq(1)
          expect(response["authors"]).to include("name" => coauthor.name)
        end

        it "does not return a main author" do
          expect(response["author"]).to eq(nil)
        end
      end
    end
  end
end

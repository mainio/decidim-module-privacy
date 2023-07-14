# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { described_class }
    let!(:organization) { create(:organization) }
    let!(:published_user) { create(:user, :confirmed, :published, organization: organization) }
    let!(:private_user) { create(:user, :confirmed, organization: organization) }

    describe "#default_scope" do
      it "returns published users by default" do
        result = subject.all
        expect(result).to include(published_user)
        expect(result).not_to include(private_user)
      end
    end

    describe "#entire_collection" do
      it "rerutns entire_collection when scoped" do
        result = subject.entire_collection.all
        expect(result).to include(published_user)
        expect(result).to include(private_user)
      end
    end

    describe "#profile_private" do
      it "returns private when scoped" do
        result = subject.profile_private.all
        expect(result).not_to include(published_user)
        expect(result).to include(private_user)
      end
    end

    describe "#public?" do
      it "return true if user is public" do
        expect(private_user).not_to be_public
        expect(published_user).to be_public
      end
    end

    describe "#private_messaging_disabled?" do
      it "returns true only if use is public and disabled messaging" do
        expect(private_user).not_to be_private_messaging_disabled
        expect do
          published_user.update(allow_private_messaging: false)
        end.to change(published_user, :private_messaging_disabled?).from(false).to(true)
      end
    end

    describe "#private_or_no_messaging?" do
      it "returns true if private or no_messaging" do
        expect(private_user).to be_private_or_no_messaging
        expect do
          published_user.update(allow_private_messaging: false)
        end.to change(published_user, :private_or_no_messaging?).from(false).to(true)
      end
    end

    describe "#accepts_conversation?" do
      let!(:user) { create(:user, :published, :confirmed, organization: organization) }

      it "returns false if private messaging is turned off" do
        published_user.update(allow_private_messaging: false)

        expect(published_user.accepts_conversation?(user)).to be(false)
      end
    end
  end
end

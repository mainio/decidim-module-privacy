# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::EndorsableHelperExtensions do
  let(:endorsements_enabled) { true }
  let(:user) { create(:user, :confirmed) }

  describe "#endorsements_enabled?" do
    subject { helper.endorsements_enabled? }

    before do
      allow(helper).to receive_messages(current_settings: double(endorsements_enabled:), current_user: user)
    end

    context "when user is private" do
      it "does not allow endorsing" do
        expect(subject).to be(false)
      end
    end

    context "when user is public" do
      let(:user) { create(:user, :confirmed, :published) }

      it "allows endorsing" do
        expect(subject).to be(true)
      end
    end
  end

  describe "#show_endorsements_card?" do
    subject { helper.show_endorsements_card? }

    context "when user not logged in" do
      it "returns false" do
        allow(helper).to receive(:current_user).and_return(nil)

        expect(subject).to be(false)
      end
    end

    context "when user logged in" do
      it "returns true" do
        allow(helper).to receive(:current_user).and_return(user)

        expect(subject).to be(true)
      end
    end
  end
end

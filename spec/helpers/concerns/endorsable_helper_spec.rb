# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Privacy
    describe EndorsableHelperExtensions do
      let(:endorsements_enabled) { true }
      let(:user) { create(:user, :confirmed) }

      subject { helper.endorsements_enabled? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(endorsements_enabled: endorsements_enabled))
        allow(helper).to receive(:current_user).and_return(user)
      end

      context "when user is private" do
        it "doesn't allow endorsing" do
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
  end
end

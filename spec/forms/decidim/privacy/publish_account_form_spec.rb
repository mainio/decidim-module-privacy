# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Privacy
    describe PublishAccountForm do
      subject(:form) { described_class.from_params(attributes) }

      let(:attributes) do
        { agree_public_profile: agree_public_profile }
      end

      describe "#agree_public_profile" do
        context "when everything is ok" do
          let(:agree_public_profile) { true }

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "when nil" do
          let(:agree_public_profile) { nil }

          it "is invalid" do
            expect(subject).to be_invalid
          end
        end

        context "when is false" do
          let(:agree_public_profile) { false }

          it "is valid" do
            expect(subject).to be_invalid
          end
        end
      end
    end
  end
end

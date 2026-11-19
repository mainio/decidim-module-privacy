# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::AnonymityForm do
  subject(:form) { described_class.from_params(attributes) }

  let(:attributes) do
    { set_anonymity: }
  end

  describe "#set_anonymity" do
    context "when everything is ok" do
      let(:set_anonymity) { true }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when nil" do
      let(:set_anonymity) { nil }

      it "is invalid" do
        expect(subject).to be_invalid
      end
    end

    context "when is false" do
      let(:set_anonymity) { false }

      it "is invalid" do
        expect(subject).to be_invalid
      end
    end
  end
end

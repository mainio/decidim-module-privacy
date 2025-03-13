# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::PrivacySettingsForm do
  subject { described_class.from_model(user).with_context(context) }

  let(:organization) { create(:organization) }
  let(:context) { { current_organization: organization } }
  let(:user) { create(:user, organization: organization) }

  describe "#map_model" do
    context "when private user" do
      it "maps the model correctly", :anonymity do
        expect(subject.published_at).to be(false)
        expect(subject.allow_private_messaging).to be(true)
        expect(subject.allow_public_contact).to be(true)
        expect(subject.anonymity).to be_nil
      end
    end

    context "when anonymous user", :anonymity do
      let(:user) { create(:user, :anonymous, organization: organization) }

      it "maps the model correctly" do
        expect(subject.published_at).to be(false)
        expect(subject.allow_private_messaging).to be(true)
        expect(subject.allow_public_contact).to be(true)
        expect(subject.anonymity).to be(true)
      end
    end

    context "with public user" do
      let!(:user) { create(:user, organization: organization, published_at: Time.current) }

      it "maps the model correctly" do
        expect(subject.published_at).to be(true)
      end
    end

    context "with no direct message allowed" do
      let!(:user) { create(:user, :published, organization: organization, allow_private_messaging: false) }

      it "maps the model correctly" do
        expect(subject.allow_private_messaging).to be(false)
      end
    end
  end
end

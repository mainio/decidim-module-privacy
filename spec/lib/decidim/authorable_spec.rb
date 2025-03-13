# frozen_string_literal: true

require "spec_helper"

describe Decidim::Authorable do
  let(:component) { create :meeting_component }
  let(:user) { create(:user, :published, :confirmed, organization: component.organization) }
  let(:resource) { create(:meeting, component: component, author: user) }

  describe "#authored_by?" do
    subject { resource.authored_by?(user) }

    context "when resource is a meeting" do
      context "when user public" do
        it "finds author" do
          expect(subject).to be(true)
        end
      end

      context "when user private" do
        let(:user) { create(:user, :confirmed, organization: component.organization) }

        it "finds author" do
          expect(subject).to be(true)
        end
      end

      context "when user anonymous", :anonymity do
        let(:user) { create(:user, :anonymous, :confirmed, organization: component.organization) }

        it "finds author" do
          expect(subject).to be(true)
        end
      end
    end

    context "when resource is a debate" do
      let(:component) { create :debates_component }
      let(:resource) { create :debate, author: user, component: component }

      context "when user public" do
        it "finds author" do
          expect(subject).to be(true)
        end
      end

      context "when user private" do
        let(:user) { create(:user, :confirmed, organization: component.organization) }

        it "finds author" do
          expect(subject).to be(true)
        end
      end

      context "when user anonymous", :anonymity do
        let(:user) { create(:user, :anonymous, :confirmed, organization: component.organization) }

        it "finds author" do
          expect(subject).to be(true)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:resource) { create(:user, :confirmed, organization:) }
  let(:participatory_space) { nil }
  let(:component) { nil }

  describe "#create!" do
    subject { Decidim::ActionLog.create!(attributes) }

    let(:attributes) do
      {
        user:,
        organization:,
        action: "invite",
        resource:,
        resource_id: resource.id,
        resource_type: resource.class.name,
        extra: {
          invited_user_role: "admin",
          invited_user_id: resource.id
        },
        visibility: "admin-only"
      }
    end

    it "knows its user" do
      expect(subject).to be_a(Decidim::ActionLog)
    end
  end
end

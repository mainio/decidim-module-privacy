# frozen_string_literal: true

require "spec_helper"

describe Decidim::EndorseResource do
  let(:resource) { create(:dummy_resource) }
  let(:current_user) { create(:user, :confirmed, :published, organization: resource.component.organization) }
  let(:command) { described_class.new(resource, current_user) }

  context "when user public" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end
  end

  context "when user private" do
    let!(:current_user) { create(:user, :confirmed, organization: resource.organization) }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end
end

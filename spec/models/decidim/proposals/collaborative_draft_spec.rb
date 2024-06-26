# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraft do
  subject { collaborative_draft }

  let(:organization) { component.participatory_space.organization }
  let(:component) { create(:proposal_component) }
  let(:collaborative_draft) { create(:collaborative_draft, component:, users: authors) }

  describe "#authors" do
    let(:private_user) { create(:user, :confirmed, organization:) }
    let(:public_users) { create_list(:user, 3, :confirmed, :published, organization:) }
    let(:authors) { public_users + [private_user] }

    it "filters out private authors" do
      expect(subject.authors).not_to include(private_user)
      expect(subject.authors).to match_array(public_users)
    end
  end

  describe "editable_by" do
    let(:authors) { [private_user, public_user] }
    let(:public_user) { create(:user, :confirmed, :published, organization:) }
    let(:private_user) { create(:user, :confirmed, organization:) }

    it "is editable by public author" do
      expect(subject.editable_by?(public_user)).to be true
    end

    it "is not editable by private author" do
      expect(subject.editable_by?(private_user)).not_to be true
    end
  end
end

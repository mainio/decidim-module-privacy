# frozen_string_literal: true

require "spec_helper"

describe Decidim::Organization, :anonymity do
  subject { organization }

  let!(:organization) { create(:organization) }
  let!(:private_admin) { create(:user, :admin, organization:) }
  let!(:anonymous_admin) { create(:user, :anonymous, :admin, organization:) }
  let!(:public_admin) { create(:user, :admin, :published, organization:) }
  let!(:private_user) { create(:user, :user_manager, organization:) }
  let!(:anonymous_user) { create(:user, :anonymous, :user_manager, organization:) }
  let!(:public_user) { create(:user, :user_manager, :published, organization:) }

  describe "#admin" do
    it "returns entire collection" do
      expect(subject.admins).to include(private_admin)
      expect(subject.admins).to include(anonymous_admin)
      expect(subject.admins).to include(public_admin)
    end
  end

  describe "#users_with_any_role" do
    it "return entire collection of rolled users" do
      expect(subject.users_with_any_role).not_to include(private_admin)
      expect(subject.users_with_any_role).not_to include(anonymous_admin)
      expect(subject.users_with_any_role).not_to include(public_admin)
      expect(subject.users_with_any_role).to include(private_user)
      expect(subject.users_with_any_role).to include(anonymous_user)
      expect(subject.users_with_any_role).to include(public_user)
    end
  end
end

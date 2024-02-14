# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::InviteAdmin do
  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:form) do
    Decidim::InviteUserForm.from_params(
      email: "newadmin@example.org",
      name: "New Admin",
      invitation_instructions: "invite_admin",
      invited_by: current_user,
      role: "admin"
    ).with_context(
      current_organization: organization,
      current_user: current_user
    )
  end
  let(:command) { described_class.new(form) }

  describe "#call" do
    subject { command.call }

    it "broadcasts ok" do
      expect { subject }.to broadcast(:ok)

      user = Decidim::User.entire_collection.order(id: :desc).first
      expect(user.admin).to be(true)
      expect(user.email).to eq(form.email)
      expect(user.name).to eq(form.name)
    end

    context "when the user exists with the given email" do
      let!(:existing_user) { create(:user, :confirmed, name: "Existing User", email: form.email, organization: organization) }

      it "elevates the user to admin" do
        expect { subject }.to broadcast(:ok)

        user = Decidim::User.entire_collection.order(id: :desc).first
        expect(user.admin).to be(true)
        expect(user.email).to eq(form.email)
        expect(user.name).to eq("Existing User")
      end
    end
  end
end

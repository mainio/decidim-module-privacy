# frozen_string_literal: true

require "spec_helper"

describe Decidim::Privacy::Admin::CreateMemberExtensions do
  subject { Decidim::Admin::ParticipatorySpace::CreateMember.new(form, privatable_to, via_csv:) }

  let!(:via_csv) { false }
  let!(:privatable_to) { create(:participatory_process) }
  let!(:email) { "my_email@example.org" }
  let!(:name) { "Weird Guy" }
  let!(:user) { create(:user, email: "my_email@example.org", organization: privatable_to.organization) }
  let!(:current_user) { create(:user, email: "some_email@example.org", organization: privatable_to.organization) }
  let!(:form) do
    double(
      invalid?: invalid,
      delete_current_members?: delete,
      email:,
      current_user:,
      name:
    )
  end
  let(:delete) { false }
  let(:invalid) { false }

  it "finds private users" do
    expect(subject.send(:existing_user)).to eq(user)
  end
end

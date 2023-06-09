# frozen_string_literal: true

require "spec_helper"

describe "Conversations", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, :with_steps, organization: organization }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    login_as user, scope: :user
    switch_to_host(organization.host)
  end

  context "when profile has private messaging turned off" do
    it "blocks people from sending messages to them" do
      expect(page).to have_content("shee")
    end
  end

end

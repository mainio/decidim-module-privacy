# frozen_string_literal: true

require "spec_helper"

describe "Conversations", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { (create :participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:receiver) { create(:user, :confirmed, organization: organization) }

  before do
    login_as user, scope: :user
    switch_to_host(organization.host)
  end

  context "when profile has private messaging turned off" do
    it "blocks people from sending messages to them" do
      receiver.update(published_at: Time.current, allow_private_messaging: false)
      user.update(published_at: Time.current)
      visit decidim.profile_path(nickname: receiver.nickname)

      find(".user-contact_link").click

      expect(page).to have_content("This user is private")
    end
  end

  context "when profile has private messaging turned on" do
    it "allows people to send messages to them" do
      user.update(published_at: Time.current)
      receiver.update(published_at: Time.current, allow_private_messaging: false)
      visit decidim.profile_path(nickname: receiver.nickname)

      find(".user-contact_link").click
      fill_in "#conversation_body", with: "Hello there receiver!"
      click_button "Send"

      expect(page).to have_selector(".p-s")
      expect(page).to have_content("Hello there receiver!")
    end
  end
end

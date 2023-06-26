# frozen_string_literal: true

require "spec_helper"

describe "User privacy", type: :system do
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when user private" do
    context "when opening user menu" do
      it "doesn't have 'my public profile' link" do
        click_link user.name
        expect(page).not_to have_link("My public profile")
      end
    end
  end

  context "when user public" do
    context "when opening user menu" do
      it "has 'my public profile' link" do
        user.update(published_at: Time.current)

        refresh
        click_link user.name
        expect(page).to have_link("My public profile")
      end
    end
  end

  context "when visiting 'privacy settings' page" do
    context "when private account" do
      it "doesn't show 'private messaging' settings" do
        visit "/privacy_settings"

        expect(page).to have_content("Enable public profile")
        expect(page.find("#user_published_at", visible: :hidden)).not_to be_checked
        expect(page).not_to have_content("Private messaging")
        expect(page).not_to have_content("Enable private messaging")
        expect(page).not_to have_content("Allow anyone to send me a direct message, even if I don't follow them.")
      end
    end

    context "when publishing your account" do
      it "shows 'private messaging' settings" do
        visit "/privacy_settings"

        expect(page).to have_content("Enable public profile")
        expect(page.find("#user_published_at", visible: :hidden)).not_to be_checked
        find("label[for='user_published_at']").click
        expect(page).to have_content("Private messaging")
        expect(page).to have_content("Enable private messaging")
        expect(page).to have_content("Allow anyone to send me a direct message, even if I don't follow them.")
      end
    end

    context "when changing settings to opposite of default values" do
      it "saves the settings for the user" do
        visit "/privacy_settings"

        expect(user.published_at).to be_nil
        expect(user.allow_private_messaging).to be(true)
        expect(user.direct_message_types).to eq("all")

        expect(page.find("#user_published_at", visible: :hidden)).not_to be_checked

        find("label[for='user_published_at']").click
        expect(page.find("#user_published_at", visible: :hidden)).to be_checked

        expect(page.find("#user_allow_private_messaging", visible: :hidden)).to be_checked
        expect(page.find("#user_allow_public_contact", visible: :hidden)).to be_checked

        find("label[for='user_allow_private_messaging']").click
        expect(page.find("#user_allow_private_messaging", visible: :hidden)).not_to be_checked
        find(".allow_public_contact").click
        expect(page.find("#user_allow_public_contact", visible: :hidden)).not_to be_checked
        click_button "Save privacy settings"
        expect(page).to have_content("Your privacy settings were successfully updated.")

        user.reload
        expect(user.published_at).to be_present
        expect(user.allow_private_messaging).to be(false)
        expect(user.direct_message_types).to eq("followed-only")
      end
    end
  end

  context "when trying to create a new proposal" do
    let!(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component

      expect(page).to have_content("New proposal")
      click_link "New proposal"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "In order to perform any public actions on this platform, you need to make your profile public. This means that a public profile about you will be provided on this platform where other people can see the following information about you:"
      )

      find("#publish_account_agree_public_profile").check

      click_button "Make your profile public"

      expect(page).to have_content("CREATE YOUR PROPOSAL")
      expect(page).to have_content("Title")
      expect(page).to have_content("Body")
    end

    context "when trying to visit url for creating a new proposal" do
      it "renders a custom page with a prompt which has to be accepted in order to proceed" do
        visit new_proposal_path(component)

        expect(page).to have_content("Publication of account needed")
        expect(page).to have_content("You are trying to access a page which requires your account to be public. Making your profile public allows other users to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

        click_button "Publish your profile"

        find("#publish_account_agree_public_profile").check

        click_button "Make your profile public"

        expect(page).to have_content("CREATE YOUR PROPOSAL")
        expect(page).to have_content("Title")
        expect(page).to have_content("Body")
      end
    end
  end

  context "when trying to create a new meeting" do
    let!(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component

      expect(page).to have_content("New meeting")
      click_link "New meeting"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "In order to perform any public actions on this platform, you need to make your profile public. This means that a public profile about you will be provided on this platform where other people can see the following information about you:"
      )

      find("#publish_account_agree_public_profile").check

      click_button "Make your profile public"

      expect(page).to have_content("CREATE YOUR MEETING")
      expect(page).to have_content("Title")
      expect(page).to have_content("Description")
    end

    context "when trying to visit url for creating a new meeting" do
      it "renders a custom page with a prompt which has to be accepted in order to proceed" do
        visit new_meeting_path(component)

        expect(page).to have_content("Publication of account needed")
        expect(page).to have_content("You are trying to access a page which requires your account to be public. Making your profile public allows other users to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

        click_button "Publish your profile"

        find("#publish_account_agree_public_profile").check

        click_button "Make your profile public"

        expect(page).to have_content("CREATE YOUR MEETING")
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
      end
    end
  end

  context "when trying to create a new debate" do
    let!(:component) { create(:debates_component, :with_creation_enabled, participatory_space: participatory_process) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component

      expect(page).to have_content("New debate")
      click_link "New debate"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "In order to perform any public actions on this platform, you need to make your profile public. This means that a public profile about you will be provided on this platform where other people can see the following information about you:"
      )

      find("#publish_account_agree_public_profile").check

      click_button "Make your profile public"

      expect(page).to have_content("NEW DEBATE")
      expect(page).to have_content("Title")
      expect(page).to have_content("Description")
    end

    context "when trying to visit url for creating a new debate" do
      it "renders a custom page with a prompt which has to be accepted in order to proceed" do
        visit new_debate_path(component)

        expect(page).to have_content("Publication of account needed")
        expect(page).to have_content("You are trying to access a page which requires your account to be public. Making your profile public allows other users to see information about you.")
        expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

        click_button "Publish your profile"

        find("#publish_account_agree_public_profile").check

        click_button "Make your profile public"

        expect(page).to have_content("NEW DEBATE")
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
      end
    end
  end

  context "when trying to leave a comment on the site" do
    let!(:component) { create(:post_component, participatory_space: participatory_process) }
    let!(:post) { create(:post, component: component) }

    it "gives you a popup for consent, which has to be accepted in order to proceed" do
      visit_component
      click_link "Processes"
      first(:link, participatory_process.title["en"]).click
      click_link "Blog"

      click_link post.title["en"]
      fill_in "add-comment-Post-#{post.id}", with: "Hello there!"
      click_button "Send"

      expect(page).to have_content("Make your profile public")
      expect(page).to have_content(
        "In order to perform any public actions on this platform, you need to make your profile public. This means that a public profile about you will be provided on this platform where other people can see the following information about you:"
      )

      find("#publish_account_agree_public_profile").check

      click_button "Make your profile public"

      expect(page).to have_content("Hello there!")
    end
  end

  def new_proposal_path(component)
    Decidim::EngineRouter.main_proxy(component).new_proposal_path(component.id)
  end

  def new_meeting_path(component)
    Decidim::EngineRouter.main_proxy(component).new_meeting_path(component.id)
  end

  def new_debate_path(component)
    Decidim::EngineRouter.main_proxy(component).new_debate_path(component.id)
  end

  def visit_component
    page.visit main_component_path(component)
  end
end

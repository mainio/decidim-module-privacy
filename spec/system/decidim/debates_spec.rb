# frozen_string_literal: true

require "spec_helper"
require "decidim/privacy/test/rspec_support/component"

describe "Debates" do
  include ComponentTestHelper

  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  context "when trying to create a new debate" do
    let!(:component) { create(:debates_component, :with_creation_enabled, participatory_space: participatory_process) }

    context "when anonymity disabled" do
      it "gives you a publicity popup for consent, which has to be accepted in order to proceed" do
        visit_component

        expect(page).to have_content("New debate")
        click_on "New debate"

        expect(page).to have_content("Make your profile public")
        expect(page).to have_content(
          "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
        )

        find_by_id("publish_account_agree_public_profile").check

        click_on "Make your profile public"

        expect(page).to have_content("New debate")
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
      end

      context "when trying to visit url for creating a new debate" do
        it "renders a custom page with a prompt which has to be accepted in order to proceed" do
          visit new_debate_path(component)

          expect(page).to have_content("Public profile is required for this action")
          expect(page).to have_content("You are trying to access a page which requires your profile to be public. Making your profile public allows other participants to see information about you.")
          expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

          click_on "Publish your profile"

          find_by_id("publish_account_agree_public_profile").check

          click_on "Make your profile public"

          expect(page).to have_content("New debate")
          expect(page).to have_content("Title")
          expect(page).to have_content("Description")
        end
      end
    end

    context "when anonymity enabled", :anonymity do
      context "when creating a debate" do
        context "when anonymous while being part of a user group" do
          let!(:user) { create(:user, :anonymous, :confirmed, organization:) }
          let!(:user_group) { create(:user_group, :confirmed, :verified, users: [user], organization: user.organization) }

          it "create as -field has a help text" do
            visit_component
            expect(page).to have_content("New debate")
            click_on "New debate"

            expect(page).to have_content("New debate")
            expect(page).to have_content("Title")
            expect(page).to have_content("Description")
            within "label[for='debate_user_group_id']" do
              expect(page).to have_content("Your profile is anonymous. If you use your own account for creation, your name is not visible unless you later decide to make your profile public.")
            end
          end
        end

        context "when pressing create new debate -button" do
          it "gives you an anonymity popup for consent, which has to be accepted in order to proceed" do
            visit_component

            expect(page).to have_content("New debate")
            click_on "New debate"

            expect(page).to have_css("#anonymityModal")
            expect(page).to have_content(
              "Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others."
            )

            click_on "Continue anonymously"

            expect(page).to have_content("New debate")
            expect(page).to have_content("Title")
            expect(page).to have_content("Description")
          end
        end
      end

      context "when 'I want my profile to be public' is pressed" do
        it "gives you a publicity popup for consent" do
          visit_component

          expect(page).to have_content("New debate")

          click_on "New debate"
          expect(page).to have_css("#anonymityModal")
          click_on "I want my profile to be public"

          expect(page).to have_css("#publishAccountModal")
          expect(page).to have_content(
            "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
          )

          find_by_id("publish_account_agree_public_profile").check

          click_on "Make your profile public"

          expect(page).to have_content("New debate")
          expect(page).to have_content("Title")
          expect(page).to have_content("Description")
        end

        context "when 'I want to continue anonymously' is pressed instead of making profile public" do
          it "keeps user anonymous and redirects to new debate page" do
            visit_component

            expect(page).to have_content("New debate")

            click_on "New debate"
            expect(page).to have_css("#anonymityModal")
            click_on "I want my profile to be public"

            expect(page).to have_css("#publishAccountModal")
            expect(page).to have_content(
              "If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:"
            )

            click_on "No, I do not want to make my profile public, continue anonymously"

            expect(page).to have_content("New debate")
            expect(page).to have_content("Title")
            expect(page).to have_content("Description")
          end
        end
      end

      context "when trying to visit url for creating a new debate" do
        it "renders a custom page with a prompt which has to be accepted in order to proceed" do
          visit new_debate_path(component)

          expect(page).to have_content("Your profile is anonymous")
          expect(page).to have_content("You are entering a page anonymously. If you want, you can change your profile privacy in your account settings.")
          expect(page).to have_content("Additional information about making your profile public will be presented after clicking the button below.")

          click_on "Continue"

          expect(page).to have_css("#anonymityModal")
          expect(page).to have_content(
            "Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others."
          )

          click_on "Continue anonymously"

          expect(page).to have_content("New debate")
          expect(page).to have_content("Title")
          expect(page).to have_content("Description")
        end
      end
    end
  end

  context "when user has created a debate" do
    let!(:component) { create(:debates_component, :with_creation_enabled, participatory_space: participatory_process) }
    let!(:debate) { create(:debate, author: user, component:) }

    context "when anonymity disabled" do
      context "when user tries to edit debate" do
        context "when user private" do
          it "doesn't render edit button" do
            visit_component
            click_on debate.title["en"]

            expect(page).to have_no_link("Edit")
          end
        end
      end
    end

    context "when anonymity enabled", :anonymity do
      let!(:user) { create(:user, :anonymous, :confirmed, organization:) }

      context "when user tries to edit debate" do
        context "when user anonymous" do
          it "renders edit button" do
            visit_component
            click_on debate.title["en"]

            expect(page).to have_link("Edit")
          end
        end
      end
    end
  end

  def new_debate_path(component)
    Decidim::EngineRouter.main_proxy(component).new_debate_path(component.id)
  end
end

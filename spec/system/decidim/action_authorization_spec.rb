# frozen_string_literal: true

require "spec_helper"

describe "ActionAuthorizationModal", :anonymity do
  include_context "with a component"

  let(:manifest_name) { "proposals" }

  let!(:organization) do
    create(:organization, available_authorizations: [authorization])
  end

  let!(:proposal) { create(:proposal, component:) }

  let!(:component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest:,
      participatory_space:,
      permissions:
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when using a handler authorization", with_authorization_workflows: ["dummy_authorization_handler"] do
    let(:authorization) { "dummy_authorization_handler" }

    context "and action authorized" do
      let(:permissions) do
        { create: { authorization_handlers: { dummy_authorization_handler: {} } } }
      end

      before do
        visit main_component_path(component)
        click_on "New proposal"
      end

      context "and prompts user to choose publicity status" do
        context "when anonymous status chosen" do
          it "prompts authorization" do
            expect(page).to have_content("Profile publicity")
            expect(page).to have_content("Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others.")

            click_on "Continue anonymously"

            expect(page).to have_content("Authorization required")
            expect(page).to have_content('In order to perform this action, you need to be authorized with "Example authorization"')
          end
        end

        context "when public status chosen" do
          it "prompts authorization" do
            expect(page).to have_content("Profile publicity")
            expect(page).to have_content("Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others.")

            click_on "I want my profile to be public"

            expect(page).to have_content("Make your profile public")
            expect(page).to have_content("If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:")

            check "publish_account_agree_public_profile"
            click_on "Make your profile public"

            expect(page).to have_content("Authorization required")
            expect(page).to have_content('In order to perform this action, you need to be authorized with "Example authorization"')
          end
        end

        context "when anonymous status chosen through publish modal" do
          it "prompts authorization" do
            expect(page).to have_content("Profile publicity")
            expect(page).to have_content("Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others.")

            click_on "I want my profile to be public"

            expect(page).to have_content("Make your profile public")
            expect(page).to have_content("If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:")

            click_on "No, I do not want to make my profile public, continue anonymously."

            expect(page).to have_content("Authorization required")
            expect(page).to have_content('In order to perform this action, you need to be authorized with "Example authorization"')
          end
        end
      end
    end

    context "and action authorized with custom action authorizer options" do
      let(:scope) { create(:scope, organization:) }
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567",
                  allowed_scope_id: scope.id
                }
              }
            }
          }
        }
      end

      before do
        visit main_component_path(component)
      end

      context "when the user does not match the authorization criteria" do
        context "and prompts user to choose publicity status" do
          let(:other_scope) { create(:scope, organization:) }
          let!(:user_authorization) do
            create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.second.ago,
                                  metadata: { postal_code: "1234", scope_id: other_scope.id })
          end

          context "when anonymous status chosen" do
            it "prompts user to check their authorization status" do
              click_on "New proposal"

              expect(page).to have_content("Profile publicity")
              expect(page).to have_content("Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others.")

              click_on "Continue anonymously"

              expect(page).to have_content("Not authorized")
              expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
              expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}, and your scope is #{other_scope.name["en"]}.")
            end
          end

          context "when public status chosen" do
            it "prompts user to check their authorization status" do
              click_on "New proposal"

              expect(page).to have_content("Profile publicity")
              expect(page).to have_content("Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others.")

              click_on "I want my profile to be public"

              expect(page).to have_content("Make your profile public")
              expect(page).to have_content("If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:")

              check "publish_account_agree_public_profile"
              click_on "Make your profile public"

              expect(page).to have_content("Not authorized")
              expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
              expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}, and your scope is #{other_scope.name["en"]}.")
            end
          end

          context "when anonymous status chosen through publish modal" do
            it "prompts user to check their authorization status" do
              click_on "New proposal"

              expect(page).to have_content("Profile publicity")
              expect(page).to have_content("Your profile on this platform is anonymous by default. The ideas and comments you post will appear as anonymous to others.")

              click_on "I want my profile to be public"

              expect(page).to have_content("Make your profile public")
              expect(page).to have_content("If you want to perform public activities on this platform, you must create a public profile. This means that other participants will see your name and nickname alongside your public activity on this platform, such as the proposals or comments you have submitted. The public profile displays the following information about you:")

              click_on "No, I do not want to make my profile public, continue anonymously."

              expect(page).to have_content("Not authorized")
              expect(page).to have_content("Sorry, you cannot perform this action as some of your authorization data does not match.")
              expect(page).to have_content("Participation is restricted to participants with the scope #{scope.name["en"]}, and your scope is #{other_scope.name["en"]}.")
            end
          end
        end
      end
    end
  end
end

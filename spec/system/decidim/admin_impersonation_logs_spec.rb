# frozen_string_literal: true

require "spec_helper"

describe "Admin impersonation logs", type: :system do
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let(:available_authorizations) { ["dummy_authorization_handler"] }
  let(:current_user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization: organization) }

  let(:managed) { true }
  let(:document_number) { "123456789X" }
  let(:reason) { "The person has limited digital skills." }
  let!(:impersonated_user) { create(:user, managed: managed, name: "Rigoberto", organization: organization) }

  let!(:authorization) { create(:authorization, user: impersonated_user, name: "dummy_authorization_handler") }

  before do
    switch_to_host(organization.host)
    login_as current_user, scope: :user

    # Navigate to the impersonation form
    visit decidim_admin.root_path
    click_link "Participants"
    click_link "Impersonations"
    within find("tr", text: impersonated_user.name) do
      click_link "Impersonate"
    end

    # Fill in the impersonation details and start the impersonation session
    within "form.new_impersonation" do
      # fill_in(:impersonate_user_name, with: impersonated_user.name)
      fill_in(:impersonate_user_reason, with: reason)
      fill_in :impersonate_user_authorization_document_number, with: document_number
      fill_in :impersonate_user_authorization_postal_code, with: "00210"
      page.execute_script("$('#impersonate_user_authorization_birthday').focus()")
    end
    page.find(".datepicker-dropdown .datepicker-days", text: "12").click
    expect(page).to have_selector("*[type=submit]", count: 1)
    click_button "Impersonate"
  end

  it "allows admin to check the impersonation logs" do
    click_button "Close session"

    expect(page).to have_content("successfully")

    within find("tr", text: impersonated_user.name) do
      click_link "View logs"
    end

    expect(page).to have_selector("tbody tr", count: 1)
    expect(page).to have_content(reason)
  end
end

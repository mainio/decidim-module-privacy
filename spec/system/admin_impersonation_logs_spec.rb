# frozen_string_literal: true

require "spec_helper"

describe "Admin impersonation logs" do
  let(:organization) { create(:organization, available_authorizations:) }
  let(:available_authorizations) { ["dummy_authorization_handler"] }
  let(:current_user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }

  let(:managed) { true }
  let(:document_number) { "123456789X" }
  let(:reason) { "The person has limited digital skills." }
  let!(:impersonated_user) { create(:user, managed:, name: "Rigoberto", organization:) }

  let!(:authorization) { create(:authorization, user: impersonated_user, name: "dummy_authorization_handler") }

  before do
    switch_to_host(organization.host)
    login_as current_user, scope: :user

    # Navigate to the impersonation form
    visit decidim_admin.root_path
    click_on "Participants"
    click_on "Impersonations"
    within find("tr", text: impersonated_user.name) do
      click_on "Impersonate"
    end

    # Fill in the impersonation details and start the impersonation session
    within "form.new_impersonation" do
      # fill_in(:impersonate_user_name, with: impersonated_user.name)
      fill_in(:impersonate_user_reason, with: reason)
      fill_in :impersonate_user_authorization_document_number, with: document_number
      fill_in :impersonate_user_authorization_postal_code, with: "00210"
    end
    page.find_by_id("impersonate_user_authorization_birthday").set(Time.current.strftime("%d/%m/%Y").to_s)

    click_on "Impersonate"
  end

  it "allows admin to check the impersonation logs" do
    click_on "Close session"

    expect(page).to have_content("successfully")

    within find("tr", text: impersonated_user.name) do
      click_on "View logs"
    end

    expect(page).to have_css("tbody tr", count: 1)
    expect(page).to have_content(reason)
  end
end

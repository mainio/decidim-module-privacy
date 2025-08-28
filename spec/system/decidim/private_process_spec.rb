# frozen_string_literal: true

require "spec_helper"

describe "PrivateParticipatoryProcesses" do
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, :published, organization:) }
  let!(:private_participatory_process) { create(:participatory_process, :published, organization:, private_space: true) }
  let!(:private_user) { create(:user, :confirmed, organization:) }
  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: private_user, privatable_to: private_participatory_process) }

  context "when anonymity disabled" do
    context "when user is logged in and is a \"private participatory process\" -user and also a private user" do
      before do
        switch_to_host(organization.host)
        login_as private_user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path
      end

      it "lists private participatory processes" do
        within "#processes-grid" do
          within "#processes-grid h2" do
            expect(page).to have_content("2 active processes")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(private_participatory_process.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)
        end
      end

      it "links to the individual process page" do
        first(".card__grid", text: translated(private_participatory_process.title, locale: :en)).click

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(private_participatory_process)
        expect(page).to have_content "This is a private process"
      end
    end

    context "when listing private participatory process private users and user is a private user" do
      let!(:admin) { create(:user, :admin, :confirmed, organization:) }

      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit decidim_admin_participatory_processes.edit_participatory_process_path(private_participatory_process)
        find("a[href*='participatory_space_private_users']").click
      end

      it "shows user in the list" do
        expect(page).to have_content(private_user.name)
        expect(page).to have_content(private_user.email)
      end
    end
  end

  context "when anonymity enabled", :anonymity do
    let!(:anonymous_user) { create(:user, :anonymous, :confirmed, organization:) }
    let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: anonymous_user, privatable_to: private_participatory_process) }

    context "when user is logged in and is a \"private participatory process\" -user and also a private user" do
      before do
        switch_to_host(organization.host)
        login_as anonymous_user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path
      end

      it "lists private participatory processes" do
        within "#processes-grid" do
          within "#processes-grid h2" do
            expect(page).to have_content("2 active processes")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(private_participatory_process.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)
        end
      end

      it "links to the individual process page" do
        first(".card__grid", text: translated(private_participatory_process.title, locale: :en)).click

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(private_participatory_process)
        expect(page).to have_content "This is a private process"
      end
    end

    context "when listing private participatory process private users and user is a private user" do
      let!(:admin) { create(:user, :admin, :confirmed, organization:) }

      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit decidim_admin_participatory_processes.edit_participatory_process_path(private_participatory_process)
        find("a[href*='participatory_space_private_users']").click
      end

      it "shows user in the list" do
        expect(page).to have_content(anonymous_user.name)
        expect(page).to have_content(anonymous_user.email)
      end
    end
  end
end

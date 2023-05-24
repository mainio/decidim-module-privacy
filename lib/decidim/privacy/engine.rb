# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Privacy
    # This is the engine that runs on the public interface of privacy.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Privacy

      routes do
        authenticate(:user) do
          resource :privacy_settings, only: [:show, :update], controller: "privacy_settings", path: "/privacy_settings"
          # We only let access of the xhr requests for the privacy settings update
          # match "/update_account_publicity", to: "privacy_settings#update_publicity", via: :post, constraints: ->(request) { request.xhr? }

          put "consent_to_privacy", to: "privacy_settings#update_publicity", as: "update_account_publicity", constraints: ->(request) { request.xhr? }
        end
      end

      initializer "decidim_privacy.mount_routes", before: "decidim.mount_routes" do
        Decidim::Core::Engine.routes.append do
          mount Decidim::Privacy::Engine => "/"
        end
      end

      initializer "decidim_pricacy.add_privacy_settings_to_account", before: "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.add_item :privacy_settings,
                        t("privacy_settings", scope: "layouts.decidim.user_profile"),
                        decidim_privacy.privacy_settings_path,
                        position: 1.1
        end
      end

      initializer "decidim_privacy.add_cells_view_paths", before: "decidim_comments.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Privacy::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Privacy::Engine.root}/app/views")
      end

      initializer "decidim_privacy.add_customizations", before: "decidim_comments.query_extensions" do
        config.to_prepare do
          # cells
          Decidim::CollapsibleListCell.include(
            Decidim::Privacy::CollapsibleListCellExtensions
          )

          # commands
          Decidim::UpdateNotificationsSettings.include(
            Decidim::Privacy::UpdateNotificationsSettingsExtensions
          )

          # controllers
          Decidim::ApplicationController.include(
            Decidim::Privacy::ApplicationControllerExtensions
          )
          Decidim::Comments::CommentsController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Proposals::ProposalsController.include(
            Decidim::Privacy::ProposalsControllerExtensions
          )
          Decidim::Proposals::ProposalVotesController.include(
            Decidim::Privacy::ProposalsControllerExtensions
          )
          Decidim::Proposals::CollaborativeDraftsController.include(
            Decidim::Privacy::ProposalsControllerExtensions
          )
          Decidim::Debates::DebatesController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Meetings::MeetingsController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )

          # models
          Decidim::User.include(Decidim::Privacy::UserExtensions)
          Decidim::UserGroup.include(Decidim::Privacy::UserGroupExtensions)

          # helpers
          Decidim::ActionAuthorizationHelper.include(
            Decidim::Privacy::ActionAuthorizationHelperExtensions
          )
        end
      end
    end
  end
end

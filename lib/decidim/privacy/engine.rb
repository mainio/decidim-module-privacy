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
        ActiveSupport.on_load(:active_record) do
          self::OrmAdapter = ::Decidim::Privacy::OrmAdapter
        end

        config.to_prepare do
          # cells
          Decidim::CollapsibleListCell.include(
            Decidim::Privacy::CollapsibleListCellExtensions
          )

          # commands
          Decidim::UpdateNotificationsSettings.include(
            Decidim::Privacy::UpdateNotificationsSettingsExtensions
          )
          Decidim::CreateRegistration.include(
            Decidim::Privacy::CreateRegistrationExtensions
          )

          # controllers
          Decidim::ApplicationController.include(
            Decidim::Privacy::ApplicationControllerExtensions
          )
          Decidim::Comments::CommentsController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Proposals::ProposalsController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Proposals::ProposalVotesController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Proposals::CollaborativeDraftsController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Debates::DebatesController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Meetings::MeetingsController.include(
            Decidim::Privacy::PrivacyActionsExtensions
          )
          Decidim::Admin::OfficializationsController.include(
            Decidim::Privacy::OfficializationsControllerExtensions
          )
          Decidim::Admin::ImpersonatableUsersController.include(
            Decidim::Privacy::ImpersonatableUsersControllerExtensions
          )
          Decidim::Admin::ModeratedUsersController.include(
            Decidim::Privacy::ModeratedUsersControllerExtensions
          )
          Decidim::Admin::ImpersonationsController.include(
            Decidim::Privacy::ImpersonationsControllerExtensions
          )
          Decidim::ProfilesController.include(
            Decidim::Privacy::ProfilesControllerExtensions
          )
          Decidim::UserActivitiesController.include(
            Decidim::Privacy::ProfilesControllerExtensions
          )
          Decidim::UserTimelineController.include(
            Decidim::Privacy::ProfilesControllerExtensions
          )
          Decidim::UserActivitiesController.include(
            Decidim::Privacy::UserActivitiesControllerExtensions
          )
          Decidim::Messaging::ConversationsController.include(
            Decidim::Privacy::ConversationsControllerExtensions
          )
          Decidim::Messaging::ConversationHelper.include(
            Decidim::Privacy::ConversationHelperExtensions
          )
          Decidim::Messaging::ReplyToConversation.include(
            Decidim::Privacy::ReplyToConversationExtensions
          )

          # models
          Decidim::User.include(Decidim::Privacy::UserExtensions)
          Decidim::UserGroup.include(Decidim::Privacy::UserGroupExtensions)
          Decidim::Organization.include(Decidim::Privacy::OrganizationExtensions)
          Decidim::Proposals::Proposal.include(Decidim::Privacy::CoauthorableExtensions)
          Decidim::Proposals::CollaborativeDraft.include(Decidim::Privacy::CoauthorableExtensions)

          # helpers
          Decidim::ActionAuthorizationHelper.include(
            Decidim::Privacy::ActionAuthorizationHelperExtensions
          )

          # presenters
          Decidim::UserPresenter.include(Decidim::Privacy::UserPresenterExtensions)
        end
      end
    end
  end
end

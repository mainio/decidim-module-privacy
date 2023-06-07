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
          remove_const(:OrmAdapter) if const_defined?(:OrmAdapter)
          self::OrmAdapter = ::Decidim::Privacy::OrmAdapter
        end

        config.to_prepare do
          # this has to be added because of a bug in decidim core, other 'valid_email2' gem will not be
          # available through the account form, which leads an error.
          Decidim::User # rubocop:disable Lint/Void

          # cells
          Decidim::CollapsibleListCell.include(
            Decidim::Privacy::CollapsibleListCellExtensions
          )
          Decidim::ActivityCell.include(
            Decidim::Privacy::ActivityCellExtensions
          )

          # commands
          Decidim::UpdateNotificationsSettings.include(
            Decidim::Privacy::UpdateNotificationsSettingsExtensions
          )
          # Decidim::CreateOmniauthRegistration.include(Decidim::Privacy::CreateOmniauthRegistrationExtensions)
          Decidim::CreateRegistration.include(
            Decidim::Privacy::CreateRegistrationExtensions
          )

          # controllers
          Decidim::ApplicationController.include(
            Decidim::Privacy::ApplicationControllerExtensions
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
          Decidim::Admin::OrganizationController.include(
            Decidim::Privacy::AdminOrganizationControllerExtensions
          )

          # models
          Decidim::ActionLog.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Authorization.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Identity.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::ImpersonationLog.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Notification.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Reminder.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Report.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::ShareToken.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::HasPrivateUsers.include(Decidim::Privacy::HasPrivateUsersExtensions)
          # Decidim::AuthorizationTransfer.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::UserReport.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Follow.include(Decidim::Privacy::UnscopedUserRelation)
          if decidim.const_defined?("Elections")
            Decidim::Elections::Trustee.include(Decidim::Privacy::UnscopedUserRelation)
            Decidim::Elections::Vote.include(Decidim::Privacy::UnscopedUserRelation)
            Decidim::Votings::MonitoringCommitteeMember.include(Decidim::Privacy::UnscopedUserRelation)
            Decidim::Votings::InPersonVote.include(Decidim::Privacy::UnscopedUserRelation)
          end
          Decidim::UserBlock.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::Gamification::BadgeScore.include(Decidim::Privacy::UnscopedUserRelation)
          Decidim::UserModeration.include(Decidim::Privacy::UnscopedUserRelation)

          # forms
          Decidim::AccountForm.include(Decidim::Privacy::AccountFormExtensions)
          Decidim::UserGroupForm.include(Decidim::Privacy::UserGroupFormExtensions)
          if Decidim::Privacy.apply_user_extensions?
            Decidim::User.include(Decidim::Privacy::UserExtensions)
            Decidim::UserGroup.include(Decidim::Privacy::UserGroupExtensions)
            Decidim::UserBaseEntity.include(Decidim::Privacy::UserBaseEntityExtensions)
          end

          Decidim::Organization.include(Decidim::Privacy::OrganizationExtensions)

          # helpers
          Decidim::ActionAuthorizationHelper.include(
            Decidim::Privacy::ActionAuthorizationHelperExtensions
          )

          # presenters
          Decidim::UserPresenter.include(Decidim::Privacy::UserPresenterExtensions)

          # Initialize concerns for each installed Decidim-module
          if Decidim.const_defined?("Budgets")
            # models
            Decidim::Budgets::Order.include(Decidim::Privacy::UnscopedUserRelation)
          end

          if Decidim.const_defined?("Proposals")
            # serializers
            Decidim::Proposals::ProposalSerializer.include(Decidim::Privacy::ProposalSerializerExtensions)

            # controllers
            Decidim::Proposals::ProposalsController.include(
              Decidim::Privacy::PrivacyActionsExtensions
            )
            Decidim::Proposals::ProposalVotesController.include(
              Decidim::Privacy::PrivacyActionsExtensions
            )
            Decidim::Proposals::CollaborativeDraftsController.include(
              Decidim::Privacy::PrivacyActionsExtensions
            )

            # models
            Decidim::Proposals::Proposal.include(Decidim::Privacy::CoauthorableExtensions)
            Decidim::Proposals::CollaborativeDraft.include(Decidim::Privacy::CoauthorableExtensions)
          end

          if Decidim.const_defined?("Comments")
            # controllers
            Decidim::Comments::CommentsController.include(
              Decidim::Privacy::PrivacyActionsExtensions
            )

            # models
            Decidim::Comments::Comment.include(Decidim::Privacy::ModelAuthorExtensions)
          end

          if Decidim.const_defined?("Debates")
            # controllers
            Decidim::Debates::DebatesController.include(
              Decidim::Privacy::PrivacyActionsExtensions
            )
          end

          if Decidim.const_defined?("Meetings")
            # models
            Decidim::Meetings::Invite.include(Decidim::Privacy::UnscopedUserRelation)
            # controllers
            Decidim::Meetings::MeetingsController.include(
              Decidim::Privacy::PrivacyActionsExtensions
            )
            # forms
            Decidim::Meetings::Admin::MeetingRegistrationInviteForm.include(
              Decidim::Privacy::UnscopedOrganizationUsers
            )
          end

          if Decidim.const_defined?("Admin")
            # controllers
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
          end

          if Decidim.const_defined?("Assemblies")
            # controllers
            Decidim::Assemblies::AssemblyMembersController.include(
              Decidim::Privacy::AssemblyMembersControllerExtensions
            )
          end

          if Decidim.const_defined?("Initiatives")
            # models
            Decidim::Initiative.include(Decidim::Privacy::InitiativeExtensions)
          end

          if Decidim.const_defined?("Conferences")
            # models
            Decidim::Conferences::ConferenceInvite.include(Decidim::Privacy::UnscopedUserRelation)
            Decidim::Conferences::Admin::ConferenceRegistrationInviteForm.include(
              Decidim::Privacy::UnscopedOrganizationUsers
            )
            Decidim::Conferences::ConferenceRegistration.include(Decidim::Privacy::UnscopedUserRelation)
            Decidim::ConferenceSpeaker.include(Decidim::Privacy::UnscopedUserRelation)
            Decidim::Conferences::Admin::ConferenceSpeakerForm.include(Decidim::Privacy::UnscopedOrganizationUsers)
            Decidim::ConferenceUserRole.include(Decidim::Privacy::UnscopedUserRelation)
          end
        end
      end
    end
  end
end

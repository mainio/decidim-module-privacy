# frozen_string_literal: true

module Decidim
  module Privacy
    module UserExtensions
      extend ActiveSupport::Concern

      included do
        before_update :update_followers_count

        default_scope { profile_published }

        # Provides the entire collection of users, including the unpublished
        # ones which is necessary for some relations. This
        #
        # Once the following PR is merged, this becomes useful:
        # https://github.com/decidim/decidim/pull/10939
        scope :entire_collection, -> { unscope(where: :published_at) }
        scope :profile_published, -> { where.not(published_at: nil) }
        scope :profile_private, -> { entire_collection.where(published_at: nil) }

        searchable_fields({
                            # scope_id: :decidim_scope_id,
                            organization_id: :decidim_organization_id,
                            A: :name,
                            B: :nickname,
                            datetime: :created_at
                          },
                          index_on_create: ->(user) { !user.deleted? && user.public? },
                          index_on_update: ->(user) { !user.deleted? && user.public? })

        # We need to remove the default scope for the registeration, so as to check the uniqueness of
        # accounts through all of the accounts
        def self.find_for_authentication(warden_conditions)
          organization = warden_conditions.dig(:env, "decidim.current_organization")
          entire_collection.find_by(
            email: warden_conditions[:email].to_s.downcase,
            decidim_organization_id: organization.id
          )
        end

        # This method is used to export the user record so it also needs to
        # search through the entire collection.
        def self.user_collection(user)
          entire_collection.where(id: user.id)
        end

        def public?
          return false if blocked?

          published_at.present?
        end

        def anonymous?
          return unless Decidim::Privacy.anonymity_enabled

          anonymity == true
        end

        def private_messaging_disabled?
          public? && !allow_private_messaging
        end

        def private_or_no_messaging?
          !public? || !allow_private_messaging
        end

        # this method was added to this model so it can be hidden from search
        def hidden?
          !public?
        end

        def accepts_conversation?(user)
          return follows?(user) if direct_message_types == "followed-only"
          return false unless allow_private_messaging

          true
        end

        private

        def update_followers_count
          return unless published_at_changed?

          transaction do
            if published_at.nil?
              followers.map { |follower| follower.update(following_count: follower.following_count - 1) }
            else
              followers.map { |follower| follower.update(following_count: follower.following_count + 1) }
            end
          end
        end
      end
    end
  end
end

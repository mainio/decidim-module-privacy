# frozen_string_literal: true

module Decidim
  module Privacy
    module NewCommentNotificationCreatorExtensions
      extend ActiveSupport::Concern

      included do
        def notify_author_followers
          return if comment.author.is_a?(Decidim::Privacy::PrivateUser)

          followers = comment.author.followers - already_notified_users
          @already_notified_users += followers

          notify(:comment_by_followed_user, followers: followers)
        end
      end
    end
  end
end

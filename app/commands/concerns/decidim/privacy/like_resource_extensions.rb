# frozen_string_literal: true

module Decidim
  module Privacy
    module LikeResourceExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid) unless @current_user.public? || @current_user.anonymous?

          like = build_resource_like
          if like.save
            notify_liker_followers
            broadcast(:ok, like)
          else
            broadcast(:invalid)
          end
        rescue ActiveRecord::RecordNotUnique
          broadcast(:invalid)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Privacy
    module UserBaseEntityExtensions
      extend ActiveSupport::Concern

      included do
        # A "dummy" scope to make it possible to fetch all users in case external
        # modules want to apply a `default_scope` to the user record. An example use
        # case can be seen in the `decidim-privacy` module that adds privacy
        # controls for the users by applying a `default_scope`.
        scope :entire_collection, -> { self }

        default_scope { profile_published }
        scope :profile_published, -> { where(type: "Decidim::UserGroup").or(where.not(published_at: nil)) }
      end
    end
  end
end

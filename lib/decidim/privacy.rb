# frozen_string_literal: true

require "decidim/privacy/engine"

module Decidim
  # This namespace holds the logic of the `Privacy` component. This component
  # allows users to create privacy in a participatory space.
  module Privacy
    autoload :OrmAdapter, "decidim/privacy/orm_adapter"
    autoload :CommentSerializerExtensions, "decidim/privacy/comment_serializer_extensions"

    # The default migrations and seeds can fail during the application
    # generation because of the extensions added to the User/UserGroup models,
    # mainly the default scope. This is why we need to detect if the application
    # is loaded by one of these rake tasks and skip adding the user related
    # extensions during these tasks to make them work as they normally would.
    #
    # This hopefully something we can eventually fix in the core through these
    # PRs:
    # https://github.com/decidim/decidim/pull/10934
    # https://github.com/decidim/decidim/pull/10939
    def self.apply_extensions?
      return true unless defined?(Rake)
      return false if ENV["DEV_APP_GENERATION"] == "true"

      true
    end
  end
end

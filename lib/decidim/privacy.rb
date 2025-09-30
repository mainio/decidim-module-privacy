# frozen_string_literal: true

require "decidim/privacy/engine"

module Decidim
  # This namespace holds the logic of the `Privacy` component. This component
  # allows users to create privacy in a participatory space.
  module Privacy
    include ActiveSupport::Configurable

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
      return true if ENV["NODE_ENV"] == "test"
      return false if seeding?
      return false if ENV["DEV_APP_GENERATION"] == "true"

      true
    end

    def self.seeding?
      return unless Rake.respond_to?(:application)

      all_tasks = (seeding_tasks + decidim_tasks)

      all_tasks.any? { |t| Rake.application.top_level_tasks.include?(t) }
    end

    def self.decidim_tasks
      Rake.application.top_level_tasks.select { |t| t.start_with?("decidim:") }
    end

    def self.seeding_tasks
      Rake.application.top_level_tasks.select { |t| t.start_with?("db:") }
    end

    config_accessor :anonymity_enabled do
      false
    end
  end
end

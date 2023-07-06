# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a commentable object.
    module AuthorableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in authorable objects."

      field :author, Decidim::Core::AuthorInterface, "The resource author", null: true do
        # can be an Authorable or a Coauthorable
      end

      def author
        author = if object.respond_to?(:normalized_author)
                   object&.normalized_author
                 elsif object.respond_to?(:creator_identity)
                   object&.creator_identity
                 end
        return unless author.is_a?(Decidim::UserBaseEntity)
        return if deleted?(author)
        return if author.is_a?(Decidim::User) && author.published_at.nil?

        author
      end

      private

      def deleted?(author)
        !author.deleted_at.nil?
      end
    end
  end
end

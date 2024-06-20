# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a coauthorable object.
    module CoauthorableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in coauthorable objects."

      field :authors_count, Integer,
            method: :coauthorships_count,
            description: "The total amount of co-authors that contributed to the entity. Note that this field may include also non-user authors like meetings or the organization",
            null: true

      field :author, Decidim::Core::AuthorInterface,
            description: "The resource author. Note that this can be null on official proposals or meeting-proposals",
            null: true

      def author
        author = object.creator_identity
        return unless author.is_a?(Decidim::UserBaseEntity)
        return unless public?(author)

        author
      end

      def authors
        object.user_identities.reject { |author| deleted?(author) }
      end

      field :authors, [Decidim::Core::AuthorInterface, { null: true }],
            description: "The resource co-authors. Include only users or groups of users",
            null: false

      private

      def public?(author)
        return false if deleted?(author)
        return true if author.is_a?(Decidim::UserGroup)

        author.is_a?(Decidim::User) && !author.published_at.nil?
      end

      def deleted?(author)
        return false if author.blank?

        !author.deleted_at.nil?
      end
    end
  end
end

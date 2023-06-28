# frozen_string_literal: true

module Decidim
  module Privacy
    module VersionAuthorCellExtensions
      extend ActiveSupport::Concern

      included do
        def author_name
          return nil unless author
          return author if author.is_a?(String)
          return t("decidim.version_author.show.deleted") if author.deleted?
          return t("decidim.privacy.private_account.unnamed_user") if author.published_at.nil?

          author.name
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  class VersionAuthorCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper

    def author
      model
    end

    def author_name
      return nil unless author
      return author if author.is_a?(String)
      return t("decidim.version_author.show.deleted") if author.deleted?
      return t("decidim.privacy.private_account.unnamed_user") if author.published_at.nil?

      author.name
    end
  end
end

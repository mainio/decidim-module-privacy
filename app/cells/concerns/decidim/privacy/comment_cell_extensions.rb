# frozen_string_literal: true

module Decidim
  module Privacy
    module CommentCellExtensions
      extend ActiveSupport::Concern

      included do
        private

        def cache_hash
          return @cache_hash if defined?(@cache_hash)

          hash = []
          hash.push(I18n.locale)
          hash.push(model.must_render_translation?(current_organization) ? 1 : 0)
          hash.push(model.authored_by?(current_user) ? 1 : 0)
          hash.push(model.reported_by?(current_user) ? 1 : 0)
          hash.push(model.up_votes_count)
          hash.push(model.down_votes_count)
          hash.push(model.cache_key_with_version)
          hash.push(model.author.cache_key_with_version) unless model.author.nil?
          @cache_hash = hash.join(Decidim.cache_key_separator)
        end
      end
    end
  end
end

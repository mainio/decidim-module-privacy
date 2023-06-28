# frozen_string_literal: true

module Decidim
  module Privacy
    module AuthorCellExtensions
      extend ActiveSupport::Concern

      included do
        def show
          return unless model.try(:public?)

          render
        end

        def profile_path?
          return false if options[:skip_profile_link] == true

          profile_path.present?
        end

        private

        def cache_hash
          hash = []

          hash.push(I18n.locale)
          hash.push(model.cache_key_with_version) if model.respond_to?(:cache_key_with_version)
          hash.push(from_context.cache_key_with_version) if from_context.respond_to?(:cache_key_with_version)
          hash.push(current_user.try(:id))
          hash.push(current_user.present?)
          hash.push(commentable?)
          hash.push(endorsable?)
          hash.push(actionable?)
          hash.push(withdrawable?)
          hash.push(flaggable?)
          hash.push(profile_path?) unless model.nil?
          hash.join(Decidim.cache_key_separator)
        end
      end
    end
  end
end

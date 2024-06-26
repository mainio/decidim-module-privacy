# frozen_string_literal: true

module Decidim
  module Privacy
    module AuthorCellExtensions
      extend ActiveSupport::Concern

      included do
        def profile_path?
          return false if model.nil?
          return false if model.is_a?(Decidim::NilPresenter)
          return false if options[:skip_profile_link] == true

          profile_path.present?
        end

        def display_name
          if model.is_a?(Decidim::NilPresenter)
            t("decidim.profile.private")
          elsif model.is_a?(Decidim::UserPresenter)
            decidim_sanitize(author_name)
          else
            model.deleted? ? t("decidim.profile.deleted") : decidim_sanitize(author_name)
          end
        end
      end
    end
  end
end

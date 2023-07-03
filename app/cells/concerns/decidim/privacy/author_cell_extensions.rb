# frozen_string_literal: true

module Decidim
  module Privacy
    module AuthorCellExtensions
      extend ActiveSupport::Concern

      included do
        def show
          return if model.is_a?(Decidim::NilPresenter)
          return if model.nil?
          return if model.is_a?(Decidim::UserPresenter) && model.private?

          render
        end

        def profile_path?
          return false if model.nil?
          return false if model.is_a?(Decidim::NilPresenter)
          return false if options[:skip_profile_link] == true

          profile_path.present?
        end
      end
    end
  end
end

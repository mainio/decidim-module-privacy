# frozen_string_literal: true

module Decidim
  module Privacy
    module CommentCellExtensions
      extend ActiveSupport::Concern

      included do
        private

        def cache_hash
          return @hash if defined?(@hash)

          hash = []
          hash.push(I18n.locale)
          hash.push(model.must_render_translation?(current_organization) ? 1 : 0)
          hash.push(model.authored_by?(current_user) ? 1 : 0)
          hash.push(model.reported_by?(current_user) ? 1 : 0)
          hash.push(model.cache_key_with_version)
          hash.push(model.author.cache_key_with_version) unless model.author.nil?

          @hash = hash.join(Decidim.cache_key_separator)
        end

        def author_presenter
          if model.author.respond_to?(:official?) && model.author.official?
            Decidim::Core::OfficialAuthorPresenter.new
          elsif model.user_group
            model.user_group.presenter
          else
            model.author.presenter
          end
        end
      end
    end
  end
end

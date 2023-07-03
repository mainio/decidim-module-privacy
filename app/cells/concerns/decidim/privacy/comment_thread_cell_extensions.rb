# frozen_string_literal: true

module Decidim
  module Privacy
    module CommentThreadCellExtensions
      extend ActiveSupport::Concern

      included do
        private

        def author_name
          return if model.author.nil?
          return t("decidim.components.comment.deleted_user") if model.author.deleted?

          model.author.name
        end
      end
    end
  end
end

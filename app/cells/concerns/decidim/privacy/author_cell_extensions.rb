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
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Privacy
    module CollapsibleListCellExtensions
      extend ActiveSupport::Concern

      included do
        def hidden_elements_count
          return 0 unless collapsible?

          list.select { |user| user[:published_at].present? }.size - size
        end
      end
    end
  end
end

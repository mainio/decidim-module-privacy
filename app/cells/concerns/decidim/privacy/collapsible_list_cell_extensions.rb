# frozen_string_literal: true

module Decidim
  module Privacy
    module CollapsibleListCellExtensions
      extend ActiveSupport::Concern

      included do
        def list
          model.reject { |user| user.is_a?(Decidim::NilPresenter) || !user.try(:public?) }
        end
      end
    end
  end
end

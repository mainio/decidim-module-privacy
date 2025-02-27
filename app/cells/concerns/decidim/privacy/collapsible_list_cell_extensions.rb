# frozen_string_literal: true

module Decidim
  module Privacy
    module CollapsibleListCellExtensions
      extend ActiveSupport::Concern

      included do
        def list
          model.map! do |user|
            if user.is_a?(Decidim::NilPresenter) || !user.try(:public?)
              PrivateUser.new
            else
              user
            end
          end

          # model.reject { |user| user.is_a?(Decidim::NilPresenter) || !user.try(:public?) }
        end
      end
    end
  end
end

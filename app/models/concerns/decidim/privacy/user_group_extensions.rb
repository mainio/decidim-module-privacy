# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupExtensions
      extend ActiveSupport::Concern

      def public?
        published_at.present?
      end
    end
  end
end
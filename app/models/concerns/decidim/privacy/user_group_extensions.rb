# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupExtensions
      extend ActiveSupport::Concern

      def public?
        true
      end
    end
  end
end

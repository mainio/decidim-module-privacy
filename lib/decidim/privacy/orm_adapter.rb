# frozen_string_literal: true

module Decidim
  module Privacy
    class OrmAdapter < ::OrmAdapter::ActiveRecord
      def initialize(klass)
        @klass = klass.unscoped
      end
    end
  end
end

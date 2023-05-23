# frozen_string_literal: true

module Decidim
  module Privacy
    class OrmAdapter < ::OrmAdapter::ActiveRecord
      # @see OrmAdapter::Base#get
      def get(id)
        klass.unscoped.where(klass.primary_key => wrap_key(id)).first
      end
    end
  end
end

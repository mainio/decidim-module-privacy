# frozen_string_literal: true

module Decidim
  module Privacy
    module NotificationExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :resource,
                   -> { respond_to?(:entire_collection) ? entire_collection : all },
                   foreign_key: "decidim_resource_id",
                   foreign_type: "decidim_resource_type",
                   polymorphic: true
      end
    end
  end
end

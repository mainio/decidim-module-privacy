# frozen_string_literal: true

module Decidim
  module Privacy
    module ActionLogExtensions
      extend ActiveSupport::Concern

      include Decidim::Privacy::UnscopedUserRelation

      included do
        # In case the resource happens to be a user, it has to be unscoped for
        # the resource to be found. Otherwise when trying to save such ActionLog
        # record, the validations would fail.
        belongs_to :resource,
                   lambda {
                     if klass == Decidim::User || klass == Decidim::UserBaseEntity
                       entire_collection
                     else
                       self
                     end
                   },
                   polymorphic: true,
                   optional: true
      end
    end
  end
end

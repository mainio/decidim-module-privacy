# frozen_string_literal: true

module Decidim
  module Privacy
    module ImpersonationLogExtensions
      extend ActiveSupport::Concern

      include Decidim::Privacy::UnscopedUserRelation

      included do
        privacy_scope_association_to_entire_collection(:admin)
      end
    end
  end
end

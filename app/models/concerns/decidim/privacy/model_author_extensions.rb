# frozen_string_literal: true

module Decidim
  module Privacy
    module ModelAuthorExtensions
      extend ActiveSupport::Concern

      included do
        def author
          original_record = super
          if original_record.try(:published_at).nil?
            Decidim::Privacy::PrivateUser.new(
              id: 0,
              name: "Anonymous",
              organization: original_record.organization
            )
          else
            original_record
          end
        end
      end
    end
  end
end

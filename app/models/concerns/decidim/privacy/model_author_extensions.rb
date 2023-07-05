# frozen_string_literal: true

module Decidim
  module Privacy
    module ModelAuthorExtensions
      extend ActiveSupport::Concern

      included do
        def author
          if super.try(:published_at).nil?
            Decidim::Privacy::PrivateUser.new(
              id: 0,
              name: "Anonymous"
            )
          else
            super
          end
        end
      end
    end
  end
end

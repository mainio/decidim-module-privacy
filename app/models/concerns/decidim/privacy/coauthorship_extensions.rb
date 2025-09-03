# frozen_string_literal: true

module Decidim
  module Privacy
    module CoauthorshipExtensions
      extend ActiveSupport::Concern

      included do
        def author
          return private_author if Decidim::Privacy.anonymity_enabled && private_author&.anonymous?

          super
        end

        # Allows to fetch the original author if they have not published their
        # profile. Use this extremely carefully, only meant to be used when
        # dealing with author events considering the user itself, such as
        # notifying proposal authors about something (after they hid their
        # profile).
        def private_author
          @private_author ||= Decidim::User.entire_collection.find_by(id: decidim_author_id)
        end
      end
    end
  end
end

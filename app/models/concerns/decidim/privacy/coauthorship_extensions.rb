# frozen_string_literal: true

module Decidim
  module Privacy
    module CoauthorshipExtensions
      extend ActiveSupport::Concern

      included do
        def author
          if Decidim::Privacy.anonymity_enabled
            hidden_user = Decidim::User.entire_collection.all.where(id: decidim_author_id).first

            if hidden_user&.anonymous?
              hidden_user
            else
              super
            end
          else
            super
          end
        end
      end
    end
  end
end

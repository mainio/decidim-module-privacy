# frozen_string_literal: true

module Decidim
  module Privacy
    module EndorseResourceExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid) unless @current_user.public? || @current_user.anonymous?
          return broadcast(:invalid) if existing_group_endorsement?

          endorsement = build_resource_endorsement
          if endorsement.save
            notify_endorser_followers
            broadcast(:ok, endorsement)
          else
            broadcast(:invalid)
          end
        rescue ActiveRecord::RecordNotUnique
          broadcast(:invalid)
        end
      end
    end
  end
end

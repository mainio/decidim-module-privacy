# frozen_string_literal: true

module Decidim
  module Privacy
    module RejectUserGroupExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid) unless @user_group.confirmed?
          return broadcast(:invalid) unless @user_group.valid?

          reject_user_group
          broadcast(:ok)
        end
      end
    end
  end
end

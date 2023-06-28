# frozen_string_literal: true

module Decidim
  module Privacy
    module VerifyUserGroupExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid) unless @user_group.confirmed?
          return broadcast(:invalid) unless @user_group.valid?

          verify_user_group
          broadcast(:ok)
        end
      end
    end
  end
end

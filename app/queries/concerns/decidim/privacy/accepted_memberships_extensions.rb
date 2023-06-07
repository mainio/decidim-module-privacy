# frozen_string_literal: true

module Decidim
  module Privacy
    module AcceptedMembershipsExtensions
      extend ActiveSupport::Concern

      included do
        def query
          user_group
            .possible_members
            .includes(:user)
            .where(role: %w(creator admin member))
        end
      end
    end
  end
end

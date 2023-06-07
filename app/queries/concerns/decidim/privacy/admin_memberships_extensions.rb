# frozen_string_literal: true

module Decidim
  module Privacy
    module AdminMembershipsExtensions
      extend ActiveSupport::Concern

      included do
        def query
          user_group
            .possible_members
            .includes(:user)
            .where(role: :admin)
        end
      end
    end
  end
end

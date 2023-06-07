# frozen_string_literal: true

module Decidim
  module Privacy
    module MemberMembershipsExtensions
      extend ActiveSupport::Concern

      included do
        def query
          user_group
            .possible_members
            .includes(:user)
            .where(role: :member)
        end
      end
    end
  end
end

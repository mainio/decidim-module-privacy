# frozen_string_literal: true

module Decidim
  module Privacy
    module StatsUsersCountExtensions
      extend ActiveSupport::Concern
      included do
        def query
          users = Decidim::User.entire_collection.where(organization: @organization).not_deleted.not_blocked.confirmed
          users = users.where("created_at >= ?", @start_at) if @start_at.present?
          users = users.where("created_at <= ?", @end_at) if @end_at.present?
          users.count
        end
      end
    end
  end
end

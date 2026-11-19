# frozen_string_literal: true

module Decidim
  module Privacy
    module InitiativesCommitteeMemberExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :user,
                   -> { entire_collection },
                   foreign_key: "decidim_users_id",
                   class_name: "Decidim::User"
      end
    end
  end
end

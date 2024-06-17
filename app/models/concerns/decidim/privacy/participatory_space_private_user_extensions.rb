# frozen_string_literal: true

module Decidim
  module Privacy
    module ParticipatorySpacePrivateUserExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :user, -> { entire_collection }, class_name: "Decidim::User", foreign_key: :decidim_user_id
      end
    end
  end
end

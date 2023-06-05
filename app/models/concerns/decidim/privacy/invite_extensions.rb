# frozen_string_literal: true

module Decidim
  module Privacy
    module InviteExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :user, -> { unscope(where: :published_at) }, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      end
    end
  end
end

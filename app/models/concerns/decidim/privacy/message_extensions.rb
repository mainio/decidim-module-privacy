# frozen_string_literal: true

module Decidim
  module Privacy
    module MessageExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :sender,
                   -> { entire_collection },
                   foreign_key: :decidim_sender_id,
                   class_name: "Decidim::UserBaseEntity"
      end
    end
  end
end

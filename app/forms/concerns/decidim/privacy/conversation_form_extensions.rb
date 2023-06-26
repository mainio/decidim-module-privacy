# frozen_string_literal: true

module Decidim
  module Privacy
    module ConversationFormExtensions
      extend ActiveSupport::Concern

      included do
        def check_recipient
          errors.add(:recipient_id, "User(s) missing") unless !@recipient.empty? && recipient_id.count == @recipient.count
        end
      end
    end
  end
end

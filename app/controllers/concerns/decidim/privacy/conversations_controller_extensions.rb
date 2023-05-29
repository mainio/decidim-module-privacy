# frozen_string_literal: true

module Decidim
  module Privacy
    module ConversationsControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_user!, :private_messaging_allowed?

        def private_messaging_allowed?
          return true if current_user.allow_private_messaging && current_user.published_at.present?

          render "decidim/privacy/message_block"
        end
      end
    end
  end
end

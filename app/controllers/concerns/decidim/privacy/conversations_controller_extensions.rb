# frozen_string_literal: true

module Decidim
  module Privacy
    module ConversationsControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_user!, :private_messaging_allowed?

        def private_messaging_allowed?
          return true unless current_user.private_or_no_messaging?

          render "decidim/privacy/message_block"
        end
      end
    end
  end
end

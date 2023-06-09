# frozen_string_literal: true

module Decidim
  module Privacy
    module StartConversationExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return if conversation.interlocutors(originator).count == 1 && conversation.interlocutors(originator).first.private_messaging_disabled?
          return broadcast(:invalid, form.errors.full_messages) if form.invalid?

          if conversation.save
            notify_interlocutors
            notify_comanagers if originator.is_a?(UserGroup)

            broadcast(:ok, conversation)
          else
            broadcast(:invalid, conversation.errors.full_messages)
          end
        end
      end
    end
  end
end

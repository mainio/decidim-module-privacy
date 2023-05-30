# frozen_string_literal: true

module Decidim
  module Privacy
    module ReplyToConversationExtensions
      extend ActiveSupport::Concern

      included do
        def call
          if conversation.interlocutors(sender).count == 1 && conversation.interlocutors(sender).first.private_messaging_disabled?
            return
          end

          if form.invalid?
            message.valid?
            return broadcast(:invalid, message.errors.full_messages)
          end

          if message.save
            notify_interlocutors
            notify_comanagers if sender.is_a?(UserGroup)

            broadcast(:ok, message)
          else
            broadcast(:invalid, message.errors.full_messages)
          end
        end

        def notify(recipient)
          return unless conversation.unread_count(recipient) == 1
          return unless recipient.accepts_conversation?(form.context.current_user)

          return if private_messaging_disabled?

          yield unless @already_notified.include?(recipient)
          @already_notified.push(recipient)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Privacy
    module ReplyToConversationExtensions
      extend ActiveSupport::Concern

      included do
        def call
          if conversation.interlocutors(sender).count == 1 && conversation.interlocutors(sender).first.private_or_no_messaging?
            return broadcast(:invalid, [t("private_info_html", scope: "decidim.profile")])
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
      end
    end
  end
end

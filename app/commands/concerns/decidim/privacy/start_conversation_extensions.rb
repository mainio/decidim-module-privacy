# frozen_string_literal: true

module Decidim
  module Privacy
    module StartConversationExtensions
      extend ActiveSupport::Concern

      included do
        def call
          return if conversation.interlocutors(originator).select { |recipient| recipient.instance_of?(Decidim::User) }.any?(&:private_or_no_messaging?)
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

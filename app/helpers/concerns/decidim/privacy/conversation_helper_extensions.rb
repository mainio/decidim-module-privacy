# frozen_string_literal: true

module Decidim
  module Privacy
    module ConversationHelperExtensions
      extend ActiveSupport::Concern

      included do
        def conversation_name_for(users)
          return content_tag(:span, t("decidim.profile.deleted"), class: "label label--small label--basic") if users.first.deleted?

          if users.first.public?
            content_tag = content_tag(:strong, users.first.name)
            nickname = content_tag(:span, "@#{users.first.nickname}", class: "muted")
          else
            content_tag = content_tag(:span, t("decidim.profile.private"), class: "label label--small label--basic")
            nickname = content_tag(:span, t("decidim.profile.private_info").html_safe, class: "muted")
          end

          content_tag << tag.br
          content_tag << nickname
          content_tag
        end

        def conversation_label_for(participants)
          return t("title", scope: "decidim.messaging.conversations.show", usernames: username_list(participants)) unless participants.count == 1

          chat_with_user = if participants.first.deleted?
                             t("decidim.profile.deleted")
                           elsif participants.first.public?
                             "#{participants.first.name} (@#{participants.first.nickname})"
                           else
                             t("decidim.profile.private")
                           end

          "#{t("chat_with", scope: "decidim.messaging.conversations.show")} #{chat_with_user}"
        end

        def username_list(users, shorten: false)
          content_tags = []
          first_users = shorten ? users.first(3) : users
          deleted_user_tag = content_tag(:span, t("decidim.profile.deleted"), class: "label label--small label--basic")
          private_user_tag = content_tag(:span, t("decidim.profile.private"), class: "label label--small label--basic")
          first_users.each do |u|
            content_tags.push(
              if u.deleted?
                deleted_user_tag
              elsif u.public?
                content_tag(:strong, u.name)
              else
                private_user_tag
              end
            )
          end

          return content_tags.join(", ") unless shorten
          return content_tags.join(", ") unless users.count > 3

          content_tags.push(content_tag(:strong, " + #{users.count - 3}"))
          content_tags.join(", ")
        end
      end
    end
  end
end

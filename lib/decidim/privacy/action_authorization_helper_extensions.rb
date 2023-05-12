# frozen_string_literal: true

module Decidim
  module Privacy
    module ActionAuthorizationHelperExtensions
      extend ActiveSupport::Concern
      extend ::Decidim::Privacy::PrivacyHelper
      included do
        private

        # rubocop: disable Metrics/PerceivedComplexity
        def authorized_to(tag, action, arguments, block)
          if block
            body = block
            url = arguments[0]
            html_options = arguments[1]
          else
            body = arguments[0]
            url = arguments[1]
            html_options = arguments[2]
          end

          html_options ||= {}
          resource = html_options.delete(:resource)
          permissions_holder = html_options.delete(:permissions_holder)

          if !current_user
            html_options = clean_authorized_to_data_open(html_options)

            html_options["data-open"] = "loginModal"
            url = "#"
          elsif current_user.published_at.blank?
            html_options = clean_authorized_to_data_open(html_options)
            html_options[:class] += " publish-modal"
            html_options["data-open"] = "publishAccountModal"
            url = "#"
          elsif action && !action_authorized_to(action, resource: resource, permissions_holder: permissions_holder).ok?
            html_options = clean_authorized_to_data_open(html_options)

            html_options["data-open"] = "authorizationModal"
            html_options["data-open-url"] = modal_path(action, resource)
            url = "#"
          end

          html_options["onclick"] = "event.preventDefault();" if url == ""

          if block
            send("#{tag}_to", url, html_options, &body)
          else
            send("#{tag}_to", body, url, html_options)
          end
        end
        # rubocop: enable Metrics/PerceivedComplexity
      end
    end
  end
end

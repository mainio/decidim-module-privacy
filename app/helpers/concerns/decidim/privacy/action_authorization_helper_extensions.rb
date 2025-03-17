# frozen_string_literal: true

module Decidim
  module Privacy
    module ActionAuthorizationHelperExtensions
      extend ActiveSupport::Concern

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

            html_options[:id] ||= generate_authorized_action_id(tag, action, url) unless html_options.has_key?("id")
            html_options["data-open"] = "loginModal"
            url = "#"
          elsif action && !action_authorized_to(action, resource: resource, permissions_holder: permissions_holder).ok?
            html_options = clean_authorized_to_data_open(html_options)

            html_options["data-open"] = "authorizationModal"
            html_options["data-open-url"] = modal_path(action, resource)
            url = "#"
          end

          if (controller.respond_to?(:allowed_publicly_to?) && !controller.allowed_publicly_to?(action)) ||
             (controller.respond_to?(:allowed_participation_to?) && !controller.allowed_participation_to?(action))
            html_options = clean_authorized_to_data_open(html_options)
            html_options[:id] ||= generate_authorized_action_id(tag, action, url) unless html_options.has_key?("id")
            html_options["data-privacy"] = { open: html_options["data-open"], openUrl: html_options["data-open-url"] }.compact.to_json
            html_options["data-open"] = if Decidim::Privacy.anonymity_enabled && current_user.anonymity.nil?
                                          "anonymityModal"
                                        else
                                          "publishAccountModal"
                                        end

            html_options.delete("data-open-url")
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

      private # rubocop:disable Lint/UselessAccessModifier

      def generate_authorized_action_id(tag, action, url)
        "authorize-#{Digest::MD5.hexdigest("#{tag}#{action}#{url}")}"
      end
    end
  end
end

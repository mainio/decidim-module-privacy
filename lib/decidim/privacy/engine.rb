# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Privacy
    # This is the engine that runs on the public interface of privacy.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Privacy

      routes do
        authenticate(:user) do
          resource :privacy_settings, only: [:show, :update], controller: "privacy_settings", path: "/privacy_settings"
        end
      end

      initializer "decidim_privacy.mount_routes", before: "decidim.mount_routes" do
        Decidim::Core::Engine.routes.append do
          mount Decidim::Privacy::Engine => "/"
        end
      end

      initializer "decidim_pricacy.add_privacy_settings_to_account", before: "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.add_item :privacy_settings,
                        t("privacy_settings", scope: "layouts.decidim.user_profile"),
                        decidim_privacy.privacy_settings_path,
                        position: 1.1
        end
      end
    end
  end
end

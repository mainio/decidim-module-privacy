# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_privacy: "#{base_path}/app/packs/entrypoints/decidim_privacy.js",
  decidim_account_publish_handler: "#{base_path}/app/packs/entrypoints/decidim_account_publish_handler.js",
  decidim_privacy_settings: "#{base_path}/app/packs/entrypoints/decidim_privacy_settings.js",
  decidim_privacy_user_form: "#{base_path}/app/packs/entrypoints/decidim_privacy_user_form",
  decidim_anonymity_settings: "#{base_path}/app/packs/entrypoints/decidim_anonymity_settings.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/privacy/privacy")

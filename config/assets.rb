# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_privacy: "#{base_path}/app/packs/entrypoints/decidim_privacy.js",
  decidim_account_publish_handler: "#{base_path}/app/packs/entrypoints/decidim_account_publish_handler.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/privacy/privacy")

# frozen_string_literal: true

require "decidim/dev/common_rake"

def install_module(path)
  Dir.chdir(path) do
    system("bundle exec rake decidim_privacy:install:migrations")
    system("bundle exec rake db:migrate")

    system("npm i '@tarekraafat/autocomplete.js@<=10.2.7'")
  end
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  install_module("spec/decidim_dummy_app")
end

desc "Generates a development app."
task :development_app do
  Bundler.with_original_env do
    ENV["DEV_APP_GENERATION"] = "true"

    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--seed_db",
      "--demo"
    )
  end

  install_module("development_app")
end

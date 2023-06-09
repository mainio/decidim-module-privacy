# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/privacy/version"

DECIDIM_VERSION = Decidim::Privacy.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-conferences", DECIDIM_VERSION
gem "decidim-elections", DECIDIM_VERSION
gem "decidim-privacy", path: "."

gem "bootsnap", "~> 1.4"

gem "puma", ">= 5.6.2"

gem "faker", "~> 2.14"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
  gem "decidim-initiatives", DECIDIM_VERSION

  gem "brakeman", "~> 5.2"
  # Ruby 3.0 -> (Decidim 0.27.x ->)
  # gem "net-imap", "~> 0.2.3"
  # gem "net-pop", "~> 0.1.1"
  # gem "net-smtp", "~> 0.3.1"
  gem "parallel_tests", "~> 3.7"
  gem "rubocop-faker"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end

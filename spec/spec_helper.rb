# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)
ENV["NODE_ENV"] ||= "test"

Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

# This re-registration is made because of problems with chromedriver v120.
# Selenium methods are undefined without this change.
# See: https://github.com/decidim/decidim/pull/12160
require "#{ENV.fetch("ENGINE_ROOT")}/lib/decidim/privacy/test/rspec_support/capybara"

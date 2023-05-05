# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/privacy/version"

Gem::Specification.new do |s|
  s.version = Decidim::Privacy.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-privacy"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-privacy"
  s.summary = "A module that enables privacy configurations"
  s.description = "Enable privacy configuration to Decidim."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Privacy.version
  s.metadata["rubygems_mfa_required"] = "true"
end

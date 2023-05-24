# frozen_string_literal: true

require "decidim/privacy/admin"
require "decidim/privacy/engine"
require "decidim/privacy/admin_engine"
require "decidim/privacy/component"

module Decidim
  # This namespace holds the logic of the `Privacy` component. This component
  # allows users to create privacy in a participatory space.
  module Privacy
    autoload :PrivacyHelper, "decidim/privacy/privacy_helper"
    autoload :ActionAuthorizationHelperExtensions, "decidim/privacy/action_authorization_helper_extensions"
    autoload :OrmAdapter, "decidim/privacy/orm_adapter"
  end
end

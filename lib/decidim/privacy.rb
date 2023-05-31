# frozen_string_literal: true

require "decidim/privacy/engine"

module Decidim
  # This namespace holds the logic of the `Privacy` component. This component
  # allows users to create privacy in a participatory space.
  module Privacy
    autoload :PrivacyHelper, "decidim/privacy/privacy_helper"
    autoload :OrmAdapter, "decidim/privacy/orm_adapter"
    autoload :CommentSerializerExtensions, "decidim/privacy/comment_serializer_extensions"
  end
end

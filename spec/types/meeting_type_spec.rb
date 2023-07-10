# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

require "decidim/core/test/shared_examples/authorable_interface_examples"

module Decidim
  module Meetings
    describe MeetingType, type: :graphql do
      include_context "with a graphql class type"
      let(:component) { create(:meeting_component) }
      let(:model) { create(:meeting, component: component) }

      include_examples "authorable interface"
    end
  end
end

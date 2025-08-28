# frozen_string_literal: true

module Decidim
  module Privacy
    module UserGroupHelperExtensions
      extend ActiveSupport::Concern

      included do
        def user_group_select_field(form, name, options = {})
          user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
          form.select(
            name,
            user_groups.map { |g| [g.name, g.id] },
            selected: @form.user_group_id.presence, # rubocop:disable Rails/HelperInstanceVariable
            include_blank: current_user.name,
            label: options.has_key?(:label) ? options[:label] : true,
            help_text: options[:help_text].presence
          )
        end
      end
    end
  end
end

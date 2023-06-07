# frozen_string_literal: true

module Decidim
  module Privacy
    module UnscopedUserRelation
      extend ActiveSupport::Concern

      included do
        options = reflect_on_association(:user).options
        if options.keys.include?(:optional)
          belongs_to :user, -> { entire_collection }, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: options[:optional]
        else
          belongs_to :user, -> { entire_collection }, foreign_key: "decidim_user_id", class_name: "Decidim::User"
        end
      end
    end
  end
end

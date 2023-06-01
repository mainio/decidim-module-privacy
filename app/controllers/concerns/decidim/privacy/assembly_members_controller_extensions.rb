# frozen_string_literal: true

module Decidim
  module Privacy
    module AssemblyMembersControllerExtensions
      extend ActiveSupport::Concern
      included do
        def members
          @members ||= begin
            collection = current_participatory_space.members.not_ceased
            collection.filter { |item| item.user.is_a?(::Decidim::User) && item.user.public? }
          end
        end
      end
    end
  end
end

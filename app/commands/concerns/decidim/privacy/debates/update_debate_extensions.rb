# frozen_string_literal: true

module Decidim
  module Privacy
    module Debates
      module UpdateDebateExtensions
        extend ActiveSupport::Concern

        included do
          alias_method :execute_update_resource, :update_resource unless method_defined?(:execute_update_resource)

          def update_resource
            if Decidim::Privacy.anonymity_enabled && !resource.author
              author = Decidim::UserBaseEntity.entire_collection.find_by(id: @form.debate.decidim_author_id)
              resource.author = author
            end

            execute_update_resource
          end
        end
      end
    end
  end
end

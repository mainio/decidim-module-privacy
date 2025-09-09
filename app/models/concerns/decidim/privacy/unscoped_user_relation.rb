# frozen_string_literal: true

module Decidim
  module Privacy
    module UnscopedUserRelation
      extend ActiveSupport::Concern

      class_methods do
        private

        # Modifies the existing association with the given name by adding the
        # `entire_collection` scope to that association to make it possible to
        # fetch user records through the association even if those users have
        # not published their profile.
        def privacy_scope_association_to_entire_collection(association_name)
          reflection = _reflections[association_name.to_s]
          raise "Undefined association on #{name}: #{association_name}" unless reflection

          # Find the correct association builder class
          association = reflection.association_class.name.split("::").last.sub(/Association$/, "").sub(/Polymorphic$/, "")
          builder = ActiveRecord::Associations::Builder.const_get(association)

          # Redefine the association with the modified scope
          _reflections[association_name.to_s] = builder.build(
            self,
            reflection.name,
            -> { entire_collection },
            reflection.options
          )
        end
      end

      included do
        privacy_scope_association_to_entire_collection(:user)
      end
    end
  end
end

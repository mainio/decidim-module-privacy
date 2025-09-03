# frozen_string_literal: true

module Decidim
  module Privacy
    module Debates
      module UpdateDebateExtensions
        extend ActiveSupport::Concern

        included do
          alias_method :execute_update_debate, :update_debate

          def update_debate
            if Decidim::Privacy.anonymity_enabled && !@form.debate.author
              author = Decidim::UserBaseEntity.entire_collection.find_by(id: @form.debate.decidim_author_id)
              @form.debate.author = author
            end

            execute_update_debate
          end
        end
      end
    end
  end
end

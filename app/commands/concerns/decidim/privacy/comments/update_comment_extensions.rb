# frozen_string_literal: true

module Decidim
  module Privacy
    module Comments
      module UpdateCommentExtensions
        extend ActiveSupport::Concern

        included do
          alias_method :execute_update_comment, :update_comment unless method_defined?(:execute_update_comment)

          def update_comment
            if Decidim::Privacy.anonymity_enabled && comment.author.is_a?(Decidim::Privacy::PrivateUser)
              author = Decidim::UserBaseEntity.entire_collection.find_by(id: comment.decidim_author_id)

              comment.author = author if author
            end

            execute_update_comment
          end
        end
      end
    end
  end
end

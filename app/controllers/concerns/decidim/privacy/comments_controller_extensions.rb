# frozen_string_literal: true

# REMOVE THIS EXTENSION IF YOU UPDATE "update_comment.rb" NOT TO NEED OVERRIDE

module Decidim
  module Privacy
    module CommentsControllerExtensions
      extend ActiveSupport::Concern
      included do
        def update
          set_comment
          set_commentable
          enforce_permission_to(:update, :comment, comment:)

          form = Decidim::Comments::CommentForm.from_params(
            params.merge(commentable: comment.commentable)
          ).with_context(
            current_user:,
            current_organization:
          )

          Decidim::Comments::UpdateComment.call(comment, current_user, form) do
            on(:ok) do
              respond_to do |format|
                format.js { render :update }
              end
            end

            on(:invalid) do
              respond_to do |format|
                format.js { render :update_error }
              end
            end
          end
        end
      end
    end
  end
end

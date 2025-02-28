# frozen_string_literal: true

module Decidim
  module Privacy
    module AuthorCellExtensions
      extend ActiveSupport::Concern

      included do
        def model
          @model ||= super

          return PrivateUser.new if @model.nil? || @model.blank?

          @model
        end

        def show
          if model.is_a?(PrivateUser) || model.is_a?(Decidim::NilPresenter) || (model.is_a?(Decidim::UserPresenter) && model.private?)
            render :unnamed_user
          else
            render
          end
        end

        def profile_path?
          return false if model.is_a?(PrivateUser)
          return false if model.nil?
          return false if options[:skip_profile_link] == true

          profile_path.present?
        end
      end
    end
  end
end

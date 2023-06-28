# frozen_string_literal: true

module Decidim
  module Privacy
    module CoauthorshipsCellExtensions
      extend ActiveSupport::Concern

      included do
        def presenter_for_author(authorable)
          if official?
            "#{model.class.module_parent}::OfficialAuthorPresenter".constantize.new
          else
            authorable.user_group&.presenter || authorable.try(:author).try(:presenter)
          end
        end
      end
    end
  end
end

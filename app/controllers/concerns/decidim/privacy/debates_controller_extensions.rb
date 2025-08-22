# frozen_string_literal: true

module Decidim
  module Privacy
    module DebatesControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :set_current_action, only: [:update]

        def update
          enforce_permission_to(:edit, :debate, debate:)

          @form = form(Decidim::Debates::DebateForm).from_params(params)

          Decidim::Debates::UpdateDebate.call(@form) do
            on(:ok) do |debate|
              flash[:notice] = I18n.t("debates.update.success", scope: "decidim.debates")
              redirect_to Decidim::ResourceLocatorPresenter.new(debate).path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("debates.update.invalid", scope: "decidim.debates")
              render :edit
            end
          end
        end

        private

        def set_current_action
          debate.current_action = action_name
        end
      end
    end
  end
end

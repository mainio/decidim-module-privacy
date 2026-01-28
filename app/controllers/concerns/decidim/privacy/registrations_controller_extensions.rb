# frozen_string_literal: true

# REMOVE THIS EXTENSION IF YOU UPDATE "join_meeting.rb" NOT TO NEED OVERRIDE

module Decidim
  module Privacy
    module RegistrationsControllerExtensions
      extend ActiveSupport::Concern
      included do
        def answer
          enforce_permission_to(:join, :meeting, meeting:)

          @form = form(Decidim::Forms::QuestionnaireForm).from_params(params, session_token:)

          JoinMeeting.call(meeting, current_user, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("registrations.create.success", scope: "decidim.meetings")
              redirect_to after_answer_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registrations.create.invalid", scope: "decidim.meetings")
              render template: "decidim/forms/questionnaires/show"
            end

            on(:invalid_form) do
              flash.now[:alert] = I18n.t("answer.invalid", scope: i18n_flashes_scope)
              render template: "decidim/forms/questionnaires/show"
            end
          end
        end

        def create
          enforce_permission_to(:register, :meeting, meeting:)

          @form = JoinMeetingForm.from_params(params).with_context(current_user:)

          JoinMeeting.call(meeting, current_user, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("registrations.create.success", scope: "decidim.meetings")
              redirect_after_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registrations.create.invalid", scope: "decidim.meetings")
              redirect_after_path
            end
          end
        end
      end
    end
  end
end

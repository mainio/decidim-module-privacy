# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingsController, type: :controller do
      routes { Decidim::Meetings::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:meeting_component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
      let(:meeting) { create :meeting, :online, :not_official, :published, author: user, component: meeting_component }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:params) { { component_id: meeting_component.id } }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = participatory_process
        request.env["decidim.current_component"] = meeting_component
      end

      it_behaves_like "permittable create actions"
      it_behaves_like "permittable new actions"

      describe "#update" do
        let(:params) do
          {
            id: meeting.id,
            component_id: meeting_component.id,
            meeting: {
              title: generate_localized_title,
              description: ::Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
              type_of_meeting: meeting.type_of_meeting,
              online_meeting_url: meeting.online_meeting_url,
              start_time: meeting.start_time,
              end_time: meeting.end_time,
              registration_type: meeting.registration_type,
              available_slots: meeting.available_slots,
              registration_terms: meeting.registration_terms
            }
          }
        end

        it_behaves_like "permittable update actions"
        it_behaves_like "permittable edit actions"
      end
    end
  end
end

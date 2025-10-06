# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsDigestMailer do
    let(:organization) { create(:organization, name: "O'Connor") }
    let(:user) { create(:user, :published, name: "Sarah Connor", organization:) }
    let(:notification_ids) { [notification.id] }
    let(:resource) { user }
    let(:notification) { create(:notification, user:, resource:, event_name: "decidim.events.gamification.badge_earned", event_class: "Decidim::Gamification::BadgeEarnedEvent", extra: { badge_name: "test", previous_level: 0, current_level: 2 }) }

    describe "digest_mail" do
      subject { described_class.digest_mail(user, notification_ids) }

      context "when user public" do
        it "includes the link to the profile" do
          expect(subject.body).to have_css("p.email-button.email-button__cta a", text: user.name)
          expect(subject.body).to have_link(user.name)
        end
      end

      context "when user private" do
        let(:user) { create(:user, name: "Peter Connor", organization:) }

        it "doesn't include the link to the profile" do
          expect(subject.body).to have_no_css("p.email-button.email-button__cta a", text: user.name)
          expect(subject.body).to have_no_link(user.name)
        end
      end

      context "when user anonymous", :anonymity do
        let(:user) { create(:user, :anonymous, name: "Peter Connor", organization:) }

        it "doesn't include the link to the profile" do
          expect(subject.body).to have_no_css("p.email-button.email-button__cta a", text: user.name)
          expect(subject.body).to have_no_link(user.name)
        end
      end
    end
  end
end

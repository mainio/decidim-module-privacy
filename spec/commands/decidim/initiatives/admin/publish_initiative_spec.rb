# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::PublishInitiative do
  subject { command.call }

  let(:command) { described_class.new(initiative, user) }
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, :created, organization:, author:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  # Initiative publishing tested only against anonymous users because the
  # private users are unable to create initiatives.
  context "with anonymous user", :anonymity do
    let(:author) { create(:user, :confirmed, :anonymous, organization:) }

    let(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }
    let(:author_badges_url) do
      url_helpers.profile_badges_url(
        nickname: author.nickname,
        host: organization.host
      )
    end

    it "increments the author's initiatives score" do
      expect { subject.call }.to change {
        Decidim::Gamification.status_for(author, :initiatives).score
      }.by(1)
    end

    it "sends the badge notification" do
      perform_enqueued_jobs { subject }

      badge_email = emails.find { |e| e.subject == "You have earned a new badge: Published initiatives!" }
      expect(badge_email).to be_present
      expect(badge_email.to).to include(author.email)
      expect(email_body(badge_email)).to include(author_badges_url)
    end
  end
end

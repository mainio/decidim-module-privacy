# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CreateComment do
  subject { command.call }

  include_context "when creating a comment"

  # Comment creation tested only against anonymous users because the private
  # users are unable to comment.
  context "with debate as the commentable", :anonymity do
    let(:component) { create(:debates_component, participatory_space: participatory_process) }
    let(:commentable) { create(:debate, component:) }
    let(:author) { create(:user, :anonymous, organization:) }

    let(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }
    let(:user_badges_url) do
      url_helpers.profile_badges_url(
        nickname: author.nickname,
        host: organization.host
      )
    end

    it "increments the debate comments score" do
      expect { perform_enqueued_jobs { subject } }.to change {
        Decidim::Gamification.status_for(author, :commented_debates).score
      }.by(1)
    end

    it "sends the badge notification" do
      perform_enqueued_jobs { subject }

      expect(last_email.subject).to eq("You have earned a new badge: Debates!")
      expect(last_email_body).to include(user_badges_url)
    end
  end
end

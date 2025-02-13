# frozen_string_literal: true

require "spec_helper"

describe Decidim::EmailNotificationsDigestGeneratorJob, type: :job do
  let!(:public_user) { create(:user, :published, notifications_sending_frequency: "daily") }
  let!(:private_user) { create(:user, notifications_sending_frequency: "daily") }
  let(:frequency) { "daily" }
  let(:time) { Time.now.utc }
  let(:job_class) { Class.new { include Decidim::Privacy::EmailNotificationsDigestGeneratorJobExtensions } }
  let(:job) { job_class.new }
  let(:mock_notifications) { double("notifications", pluck: [1, 2, 3]) }

  before do
    allow(Decidim::NotificationsDigestSendingDecider)
      .to receive(:must_notify?)
      .and_return(true)

    allow(Decidim::NotificationsDigestMailer)
      .to receive(:digest_mail)
      .and_return(double("mailer", deliver_later: true))

    # rubocop:disable RSpec/AnyInstance, RSpec/MessageChain
    allow_any_instance_of(Decidim::User)
      .to receive_message_chain(:notifications, :try)
      .and_return(mock_notifications)
    # rubocop:enable RSpec/AnyInstance, RSpec/MessageChain
  end

  it "updates digest_sent_at for both private and public users" do
    expect(public_user.digest_sent_at).to be_nil
    expect(private_user.digest_sent_at).to be_nil

    job.perform(public_user.id, frequency, time: time)
    job.perform(private_user.id, frequency, time: time)

    expect(public_user.reload.digest_sent_at).not_to be_nil
    expect(private_user.reload.digest_sent_at).not_to be_nil
  end
end

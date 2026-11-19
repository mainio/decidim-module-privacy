# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateAccount do
    let(:command) { described_class.new(form) }
    let!(:user) { create(:user, :confirmed, password: user_password) }
    let(:user_password) { "decidim1234567890" }
    let(:data) do
      {
        name: user.name,
        nickname: user.nickname,
        email: user.email,
        old_password: nil,
        password: nil,
        avatar: nil,
        remove_avatar: nil,
        personal_url: "https://example.org",
        about: "This is a description of me",
        locale: "es"
      }
    end

    let(:form) do
      AccountForm.from_params(
        name: data[:name],
        nickname: data[:nickname],
        email: data[:email],
        password: data[:password],
        old_password: data[:old_password],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        personal_url: data[:personal_url],
        about: data[:about],
        locale: data[:locale]
      ).with_context(current_organization: user.organization, current_user: user)
    end

    describe "updating the email" do
      let(:validator) { instance_double(ValidEmail2::Address) }

      before do
        form.email = "new@example.com"
        allow(ValidEmail2::Address).to receive(:new).and_return(validator)
        allow(validator).to receive_messages(valid?: true, disposable?: false)
      end

      context "with correct old password" do
        before do
          form.old_password = user_password
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "sends a reconfirmation email" do
          expect do
            perform_enqueued_jobs { command.call }
          end.to broadcast(:ok, true)

          expect(emails.count).to eq(2)
          expect(emails[0].subject).to eq("Instrucciones de confirmación")
          expect(emails[0].to).to eq(["new@example.com"])
          expect(emails[1].subject).to eq("Se ha actualizado tu cuenta")
          expect(emails[1].to).to eq([user.email])
        end
      end

      context "with incorrect password" do
        before do
          form.old_password = "foobar123456789"
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      context "with empty password" do
        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end

    describe "when the password is present" do
      let(:user) { create(:user, :confirmed, password: user_password, password_updated_at: 1.week.ago) }

      before do
        form.password = "pNY6h9crVtVHZbdE"
      end

      context "with incorrect old password" do
        before do
          form.old_password = "foobar1234567890"
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      context "with empty old password" do
        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      context "with correct old password" do
        before do
          form.old_password = user_password
        end

        it "updates the password" do
          expect { command.call }.to broadcast(:ok)
          expect(user.reload.valid_password?("pNY6h9crVtVHZbdE")).to be(true)
        end

        it "sets the password_updated_at to the current time" do
          expect { command.call }.to broadcast(:ok)
          expect(user.password_updated_at).to be_between(2.seconds.ago, Time.current)
        end
      end
    end
  end
end

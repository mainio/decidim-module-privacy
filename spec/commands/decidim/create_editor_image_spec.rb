# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateEditorImage do
    subject { described_class.new(form) }

    let(:form) do
      EditorImageForm.from_params(attributes).with_context(context)
    end
    let(:attributes) do
      {
        "editor_image" => {
          organization:,
          author_id: user.id,
          file:
        }
      }
    end
    let(:context) do
      {
        current_organization: organization,
        current_user: user
      }
    end
    let(:user) { create(:user, :admin, :confirmed) }
    let(:organization) { user.organization }
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    context "when the user is private" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
        expect(user.public?).to be(false)
      end

      it "creates an editor image" do
        expect { subject.call }.to change(Decidim::EditorImage, :count).by(1)
      end
    end

    context "when the user is public" do
      let(:user) { create(:user, :admin, :published, :confirmed) }
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
        expect(user.public?).to be(true)
      end

      it "creates an editor image" do
        expect { subject.call }.to change(Decidim::EditorImage, :count).by(1)
      end
    end
  end
end

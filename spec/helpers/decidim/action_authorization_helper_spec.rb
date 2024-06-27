# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionAuthorizationHelper do
  let(:component) { create(:component) }
  let(:resource) { nil }
  let(:permissions_holder) { nil }
  let(:user) { create(:user) }
  let(:action) { "foo" }
  let(:status) { double(ok?: authorized) }
  let(:authorized) { true }

  let(:widget_text) { "Link" }
  let(:path) { "fake_path" }

  before do
    allow(helper).to receive_messages(current_component: component, current_user: user)
    allow(helper).to receive(:action_authorized_to).with(action, resource:, permissions_holder:).and_return(status)
  end

  shared_examples "an action authorization widget helper" do |params|
    if params[:has_action]
      context "when the action is not authorized" do
        let(:authorized) { false }

        it "renders a widget toggling the authorization modal" do
          expect(subject).not_to include(path)
          expect(subject).to include('data-dialog-open="authorizationModal"')
          expect(subject).to include("data-dialog-remote-url=\"/authorization_modals/#{action}/f/#{component.id}\"")
          expect(subject).to include(*params[:widget_parts])
        end

        context "when called with a resource" do
          let(:resource) { create(:dummy_resource, component:) }

          it "renders a widget toggling the authorization modal" do
            expect(subject).not_to include(path)
            expect(subject).to include('data-dialog-open="authorizationModal"')
            expect(subject).to include("data-dialog-remote-url=\"/authorization_modals/#{action}/f/#{component.id}/#{resource.resource_manifest.name}/#{resource.id}\"")
            expect(subject).to include(*params[:widget_parts])
          end
        end

        context "when called with no component and permissions_holder" do
          let(:component) { nil }
          let(:resource) { create(:dummy_resource) }
          let(:permissions_holder) { resource }

          it "renders a widget toggling the authorization modal of free resources not related with a component" do
            expect(subject).not_to include(path)
            expect(subject).to include('data-dialog-open="authorizationModal"')
            expect(subject).to include("data-dialog-remote-url=\"/free_resource_authorization_modals/#{action}/f/#{resource.resource_manifest.name}/#{resource.id}\"")
            expect(subject).to include(*params[:widget_parts])
          end
        end

        describe "#allowed_publicly_to?" do
          before do
            allow(controller).to receive(:allowed_publicly_to?).and_return(allowed_publicly_to?)
            allow(Digest::MD5).to receive(:hexdigest).and_return("dummy12345678")
          end

          context "when not allowed publicly" do
            let(:allowed_publicly_to?) { false }
            let(:expected_data_privacy) do
              {
                open: "authorizationModal",
                openUrl: "/authorization_modals/foo/f/#{component.id}"
              }.compact.to_json
            end

            it "renders a widget toggling the publish account modal" do
              expect(subject).not_to include(path)
              expect(CGI.unescapeHTML(subject)).to include("data-dialog-privacy=\"#{expected_data_privacy}\"")
              expect(subject).to include('data-dialog-open="publishAccountModal"')
              expect(subject).not_to include("data-open-url")
              expect(subject).to include('id="authorize-dummy12345678"')
            end

            context "when authorized but public action" do
              let(:authorized) { true }

              it "adds data-open without data-privacy" do
                expect(subject).not_to include(path)
                expect(subject).to include("data-dialog-privacy=\"{}\"")
                expect(subject).to include('data-dialog-open="publishAccountModal"')
                expect(subject).not_to include("data-open-url")
                expect(subject).to include('id="authorize-dummy12345678"')
              end
            end
          end
        end
      end

    else
      let(:action) { nil }
    end

    context "when #{params[:has_action] ? "the action is authorized" : "the user is logged"}" do
      it "renders a regular widget" do
        expect(subject).not_to include("data-open")
        expect(subject).to include(path)
        expect(subject).to include(*params[:widget_parts])
      end
    end

    context "when there is not a logged user" do
      let(:user) { nil }

      it "renders a widget toggling the login modal" do
        expect(subject).not_to include(path)
        expect(subject).to include('data-dialog-open="loginModal"')
        expect(subject).to include(*params[:widget_parts])
      end
    end
  end

  describe "action_authorized_link_to" do
    context "when called with text" do
      subject(:rendered) { helper.action_authorized_link_to(action, widget_text, path, resource:, permissions_holder:) }

      it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<a)
    end

    context "when called with a block" do
      subject(:rendered) { helper.action_authorized_link_to(action, path, resource:, permissions_holder:) { widget_text } }

      it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<a)
    end
  end

  describe "action_authorized_button_to" do
    context "when called with text" do
      subject(:rendered) { helper.action_authorized_button_to(action, widget_text, path, resource:, permissions_holder:) }

      it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<input type="submit")
    end

    context "when called with a block" do
      subject(:rendered) { helper.action_authorized_button_to(action, path, resource:, permissions_holder:) { widget_text } }

      it_behaves_like "an action authorization widget helper", has_action: true, widget_parts: %w(<button type="submit")
    end
  end

  describe "logged_link_to" do
    context "when called with text" do
      subject(:rendered) { helper.logged_link_to(widget_text, path, resource:) }

      it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<a)
    end

    context "when called with a block" do
      subject(:rendered) { helper.logged_link_to(path, resource:) { widget_text } }

      it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<a)
    end
  end

  describe "logged_button_to" do
    context "when called with text" do
      subject(:rendered) { helper.logged_button_to(widget_text, path, resource:) }

      it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<input type="submit")
    end

    context "when called with a block" do
      subject(:rendered) { helper.logged_button_to(path, resource:) { widget_text } }

      it_behaves_like "an action authorization widget helper", has_action: false, widget_parts: %w(<button type="submit")
    end
  end
end

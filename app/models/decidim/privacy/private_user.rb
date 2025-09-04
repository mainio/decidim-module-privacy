# frozen_string_literal: true

module Decidim
  module Privacy
    class PrivateUser < ApplicationRecord
      include Decidim::HasUploadValidations

      self.table_name = "decidim_users"

      belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"

      has_one_attached :avatar
      validates_avatar :avatar, uploader: Decidim::AvatarUploader

      def name
        I18n.t("unnamed_user", scope: "decidim.privacy.private_account")
      end

      def default_avatar_url
        attached_uploader(:avatar).default_url
      end

      def confirmed?
        true
      end

      def blocked?
        false
      end

      def deleted?
        false
      end

      def public?
        false
      end

      def officialized?
        false
      end

      # Returns the presenter for this author, to be used in the views.
      # Required by ActsAsAuthor.
      def presenter
        Decidim::UserPresenter.new(self)
      end

      def self.log_presenter_class_for(_log)
        Decidim::AdminLog::UserPresenter
      end
    end
  end
end

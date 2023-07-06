# frozen_string_literal: true

module Decidim
  module Privacy
    class PrivateUser < ApplicationRecord
      self.table_name = "decidim_users"

      def deleted?
        false
      end

      def public?
        false
      end
    end
  end
end

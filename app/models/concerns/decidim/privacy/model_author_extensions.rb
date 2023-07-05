# frozen_string_literal: true

module Decidim
  module Privacy
    module ModelAuthorExtensions
      extend ActiveSupport::Concern

      included do
        def author
          if super.nil?
            Decidim::Privacy::PrivateUser.new
          else
            super
          end
        end
      end
    end
  end
end

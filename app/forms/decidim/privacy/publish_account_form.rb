# frozen_string_literal: true

module Decidim
  module Privacy
    class PublishAccountForm < Form
      attribute :agree_public_profile

      validates :agree_public_profile, acceptance: true
    end
  end
end

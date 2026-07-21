# frozen_string_literal: true

module Decidim
  module Privacy
    module ProposalPresenterExtensions
      extend ActiveSupport::Concern

      included do
        def author
          @author ||= if official?
                        Decidim::Proposals::OfficialAuthorPresenter.new
                      else
                        coauthorship = coauthorships.includes(:author).first
                        get_presenter(coauthorship)
                      end
        end

        private

        def get_presenter(coauthorship)
          coauthorship.author&.presenter unless Decidim::Privacy.anonymity_enabled && coauthorship.author&.anonymous?
        end
      end
    end
  end
end

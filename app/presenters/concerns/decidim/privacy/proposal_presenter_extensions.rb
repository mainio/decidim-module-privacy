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
                        coauthorship = coauthorships.includes(:author, :user_group).first
                        get_presenter(coauthorship)
                      end
        end

        private

        def get_presenter(coauthorship)
          if Decidim::Privacy.anonymity_enabled
            coauthorship.user_group&.presenter || (coauthorship.author&.presenter unless coauthorship.author.anonymous?)
          else
            coauthorship.user_group&.presenter || coauthorship.author&.presenter
          end
        end
      end
    end
  end
end

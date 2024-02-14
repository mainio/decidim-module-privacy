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
                        coauthorship.user_group&.presenter || coauthorship.author&.presenter
                      end
        end
      end
    end
  end
end

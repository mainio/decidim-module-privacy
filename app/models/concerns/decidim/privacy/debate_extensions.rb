# frozen_string_literal: true

module Decidim
  module Privacy
    module DebateExtensions
      extend ActiveSupport::Concern

      included do
        def current_action=(action)
          Thread.current[:debate_action] = action
        end

        def current_action
          Thread.current[:debate_action]
        end
      end
    end
  end
end

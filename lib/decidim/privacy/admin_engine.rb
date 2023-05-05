# frozen_string_literal: true

module Decidim
  module Privacy
    # This is the engine that runs on the public interface of `Privacy`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Privacy::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :privacy do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "privacy#index"
      end

      def load_seed
        nil
      end
    end
  end
end

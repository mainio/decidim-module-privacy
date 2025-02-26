# frozen_string_literal: true

module Decidim
  module Privacy
    module CoauthorableExtensions
      extend ActiveSupport::Concern
      include Decidim::Coauthorable

      included do
        def authors
          return @authors if defined?(@authors)

          authors = coauthorships.pluck(:decidim_author_id, :decidim_author_type).each_with_object({}) do |(id, klass), all|
            all[klass] ||= []
            all[klass] << id
          end
          authors = authors.flat_map do |klass, ids|
            klass.constantize.where(id: ids)
          end
          @authors = authors.filter { |author| !author.is_a?(Decidim::User) || author.published_at.present? }.compact.uniq
        end

        def created_by?(author)
          author == if Decidim::Privacy.anonymity_enabled && author.anonymous?
                      Decidim::User.entire_collection.where(id: creator.decidim_author_id).first
                    else
                      creator_author
                    end
        end
      end
    end
  end
end

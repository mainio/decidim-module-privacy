# frozen_string_literal: true

module Decidim
  module Privacy
    module UserExtensions
      extend ActiveSupport::Concern

      class_methods do
        # @see OrmAdapter::Base#find_first
        # def find_first(options = {})
        #   raise "FIND FIRST USER"
        #   construct_relation(klass, options).first
        # end

        # def find_first_by_auth_conditions(tainted_conditions, opts = {})
        #   raise "FIND FIRST"
        #   to_adapter.find_first(devise_parameter_filter.filter(tainted_conditions).merge(opts))
        # end

        # def find_for_database_authentication(conditions)
        #   raise conditions.inspect
        #   find_for_authentication(conditions)
        # end
      end

      included do
        # we need to remove the default scope for the registeration, so as to check the uniqueness of
        # accounts through all of the accounts
        default_scope { where.not(published_at: nil) }

        def self.find_for_authentication(warden_conditions)
          organization = warden_conditions.dig(:env, "decidim.current_organization")
          unscoped.find_by(
            email: warden_conditions[:email].to_s.downcase,
            decidim_organization_id: organization.id
          )
        end

        def public?
          published_at.present?
        end
      end
    end
  end
end

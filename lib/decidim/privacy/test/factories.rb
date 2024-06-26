# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :privacy_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :privacy).i18n_name }
    manifest_name { :privacy }
    participatory_space { association(:participatory_process, :with_steps) }
  end

  FactoryBot.modify do
    factory :user do
      trait :published do
        published_at { Time.current }
      end
    end
  end
end

# frozen_string_literal: true

class AddAnonymityToDecidimUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :anonymity, :boolean, null: false, default: false
  end
end

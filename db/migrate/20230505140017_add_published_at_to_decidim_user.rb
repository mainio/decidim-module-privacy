# frozen_string_literal: true

class AddPublishedAtToDecidimUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :published_at, :datetime
  end
end

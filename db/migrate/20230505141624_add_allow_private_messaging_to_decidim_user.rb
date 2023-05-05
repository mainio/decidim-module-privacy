# frozen_string_literal: true

class AddAllowPrivateMessagingToDecidimUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :allow_private_messaging, :boolean
  end
end

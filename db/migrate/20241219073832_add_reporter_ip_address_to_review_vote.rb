# frozen_string_literal: true

class AddReporterIpAddressToReviewVote < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_review_votes, :reporter_ip_address, :string
  end
end

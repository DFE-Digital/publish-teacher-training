# frozen_string_literal: true

namespace :users do
  desc "Permanently delete users where discarded_at is set"
  task delete_discarded: :environment do
    discarded_users = User.where.not(discarded_at: nil)
    total = discarded_users.count

    puts "Found #{total} discarded users to delete"

    deleted = 0
    discarded_users.find_each do |user|
      user.destroy!
      deleted += 1
    end

    puts "Deleted #{deleted} discarded users"
  end
end

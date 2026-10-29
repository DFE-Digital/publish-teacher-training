# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261029091000_delete_discarded_users")

describe DeleteDiscardedUsers do
  # discarded_at is ignored on User, so expose it while building test data.
  around do |example|
    ignored_columns = User.ignored_columns
    User.ignored_columns = []
    User.reset_column_information
    example.run
  ensure
    User.ignored_columns = ignored_columns
    User.reset_column_information
  end

  it "hard deletes users with discarded_at set and leaves other users alone" do
    discarded_user = create(:user, discarded_at: Time.zone.now)
    active_user = create(:user)

    described_class.new.up

    expect(User.exists?(discarded_user.id)).to be(false)
    expect(User.exists?(active_user.id)).to be(true)
  end
end

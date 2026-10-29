# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261029091000_delete_discarded_users")

describe DeleteDiscardedUsers do
  it "hard deletes users with discarded_at set and leaves other users alone" do
    discarded_user = create(:user)
    active_user = create(:user)
    User.connection.exec_update("UPDATE \"user\" SET discarded_at = NOW() WHERE id = #{discarded_user.id}")

    described_class.new.up

    expect(User.exists?(discarded_user.id)).to be(false)
    expect(User.exists?(active_user.id)).to be(true)
  end
end

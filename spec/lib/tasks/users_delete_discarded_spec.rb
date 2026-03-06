# frozen_string_literal: true

require "rails_helper"
require "rake"

describe "users:delete_discarded" do
  subject(:delete_discarded_users_task) do
    Rake::Task["users:delete_discarded"].invoke
  end

  Rails.application.load_tasks if Rake::Task.tasks.empty?

  before do
    Rake::Task["users:delete_discarded"].reenable
  end

  let!(:discarded_user) { create(:user, :discarded) }
  let!(:active_user) { create(:user) }

  it "deletes users with discarded_at and keeps active users" do
    expect { delete_discarded_users_task }.to change { User.where.not(discarded_at: nil).count }.from(1).to(0)

    expect(User.exists?(discarded_user.id)).to be(false)
    expect(User.exists?(active_user.id)).to be(true)
  end
end

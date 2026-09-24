# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "solid_queue:start_when_ready" do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["solid_queue:start_when_ready"].reenable
    allow(Rake::Task["solid_queue:start"]).to receive(:invoke)
  end

  it "starts Solid Queue once solid_queue_jobs has a primary key" do
    connection = ActiveRecord::Base.connection
    expect(connection.table_exists?("solid_queue_jobs")).to be(true)
    expect(connection.primary_key("solid_queue_jobs")).to be_present

    Rake::Task["solid_queue:start_when_ready"].invoke

    expect(Rake::Task["solid_queue:start"]).to have_received(:invoke)
  end

  it "waits while the primary key is missing then starts" do
    connection = instance_double(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
    allow(connection).to receive(:table_exists?).with("solid_queue_jobs").and_return(true)
    allow(connection).to receive(:primary_key).with("solid_queue_jobs").and_return(nil, nil, "id")
    allow(Kernel).to receive(:sleep)

    Rake::Task["solid_queue:start_when_ready"].invoke

    expect(Kernel).to have_received(:sleep).at_least(:once)
    expect(Rake::Task["solid_queue:start"]).to have_received(:invoke)
  end
end

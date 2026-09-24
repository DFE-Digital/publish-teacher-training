# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "solid_queue:start_when_ready" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    load Rails.root.join("lib/tasks/solid_queue_boot.rake") unless defined?(SolidQueueBoot)
  end

  before do
    Rake::Task["solid_queue:start_when_ready"].reenable
    allow(Rake::Task["solid_queue:start"]).to receive(:invoke)
  end

  it "starts Solid Queue once solid_queue tables have primary keys" do
    connection = ActiveRecord::Base.connection
    SolidQueueBoot::REQUIRED_TABLES.each do |table|
      expect(connection.table_exists?(table)).to be(true)
      expect(connection.primary_key(table)).to be_present
    end

    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("qa"))

    Rake::Task["solid_queue:start_when_ready"].invoke

    expect(Rake::Task["solid_queue:start"]).to have_received(:invoke)
  end

  it "waits while schema is not ready then starts" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("qa"))
    allow(SolidQueueBoot).to receive(:schema_ready?).and_return(false, false, true)
    allow(Kernel).to receive(:sleep)

    Rake::Task["solid_queue:start_when_ready"].invoke

    expect(Kernel).to have_received(:sleep).at_least(:once)
    expect(Rake::Task["solid_queue:start"]).to have_received(:invoke)
  end

  describe "SolidQueueBoot.schema_ready?" do
    it "is false in review until sanitised statistic rows exist" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("review"))
      allow(Statistic).to receive(:count).and_return(0)

      expect(SolidQueueBoot.schema_ready?).to be(false)
    end

    it "is true in review once solid_queue PKs and statistic rows exist" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("review"))
      allow(Statistic).to receive(:count).and_return(SolidQueueBoot::REVIEW_MIN_STATISTIC_ROWS)

      expect(SolidQueueBoot.schema_ready?).to be(true)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"
require "erb"
require "yaml"
require "fugit"

RSpec.describe "Solid Queue recurring configuration" do
  def recurring_config
    YAML.safe_load(
      ERB.new(Rails.root.join("config/recurring.yml").read).result,
      aliases: true,
    )
  end

  def section_for(env)
    recurring_config.fetch(env)
  end

  def application_job_tasks(env)
    section_for(env).reject { |_key, task| task.key?("command") }
  end

  it "keeps the Solid Queue worker skipping recurrence until cutover" do
    terraform = Rails.root.join("terraform/aks/application.tf").read

    expect(terraform).to include("SOLID_QUEUE_SKIP_RECURRING=true")
  end

  it "documents the atomic cutover and rollback steps" do
    expect(Rails.root.join("guides/solid-queue-recurring-cutover.md")).to exist
  end

  it "defines empty schedules for environments without Sidekiq Cron" do
    %w[sandbox review development test loadtest rollover].each do |env|
      expect(section_for(env)).to eq({})
    end
  end

  it "mirrors production Sidekiq Cron jobs with matching class, queue and cron" do
    production_tasks = application_job_tasks("production")

    expect(production_tasks.keys).to contain_exactly(
      "save_statistic",
      "send_entity_table_checks_to_bigquery",
      "import_gias_schools",
      "cleanup_recent_searches",
      "cleanup_school_bulk_update_drafts",
      "send_weekly_email_alerts",
    )

    expect(production_tasks["save_statistic"]).to include(
      "class" => "SaveStatisticJob",
      "queue" => "save_statistic",
      "schedule" => "0 0 * * * Europe/London",
    )
    expect(production_tasks["send_entity_table_checks_to_bigquery"]).to include(
      "class" => "DfE::Analytics::EntityTableCheckJob",
      "queue" => "low_priority",
      "schedule" => "30 0 * * * Europe/London",
    )
    expect(production_tasks["import_gias_schools"]).to include(
      "class" => "GiasImportJob",
      "queue" => "default",
      "schedule" => "30 2 * * * Europe/London",
    )
    expect(production_tasks["cleanup_recent_searches"]).to include(
      "class" => "CleanupRecentSearchesJob",
      "queue" => "default",
      "schedule" => "0 3 * * * Europe/London",
    )
    expect(production_tasks["cleanup_school_bulk_update_drafts"]).to include(
      "class" => "CleanupSchoolBulkUpdateDraftsJob",
      "queue" => "default",
      "schedule" => "0 3 * * * Europe/London",
    )
    expect(production_tasks["send_weekly_email_alerts"]).to include(
      "class" => "SendWeeklyEmailAlertsJob",
      "queue" => "default",
      "schedule" => "0 3 * * 5 Europe/London",
    )
  end

  it "mirrors QA and staging Sidekiq Cron job sets" do
    expect(application_job_tasks("qa").keys).to contain_exactly(
      "save_statistic",
      "cleanup_recent_searches",
      "cleanup_school_bulk_update_drafts",
    )
    expect(application_job_tasks("staging").keys).to contain_exactly("save_statistic")
  end

  it "routes finished Solid Queue cleanup to a consumed low-priority queue" do
    %w[production qa staging].each do |env|
      cleanup = section_for(env).fetch("clear_solid_queue_finished_jobs")
      batches = section_for(env).fetch("clear_solid_queue_finished_batches")

      expect(cleanup["command"]).to include("SolidQueue::Job.clear_finished_in_batches")
      expect(cleanup["queue"]).to eq("low_priority")
      expect(cleanup["schedule"]).to eq("every hour at minute 12")

      expect(batches["command"]).to include("SolidQueue::Batch.clear_finished_in_batches")
      expect(batches["queue"]).to eq("low_priority")
    end
  end

  it "parses every production schedule with Fugit and keeps UK midnight across spring DST" do
    midnight = Fugit::Cron.parse("0 0 * * * Europe/London")

    before_change = midnight.next_time(Time.utc(2026, 3, 28, 12, 0, 0))
    after_change = midnight.next_time(Time.utc(2026, 3, 29, 12, 0, 0))

    # UK still on GMT early on 29 Mar; next local midnight after midday BST is 23:00 UTC.
    expect(before_change.utc.iso8601).to eq("2026-03-29T00:00:00Z")
    expect(after_change.utc.iso8601).to eq("2026-03-29T23:00:00Z")

    application_job_tasks("production").each_value do |task|
      expect(Fugit.parse(task.fetch("schedule"))).to be_present
    end
  end

  it "keeps Friday weekly alerts at 03:00 Europe/London across the autumn DST boundary" do
    weekly = Fugit::Cron.parse("0 3 * * 5 Europe/London")

    # Clocks go back on 25 Oct 2026. Friday before: 23 Oct. Friday after: 30 Oct.
    before = weekly.next_time(Time.utc(2026, 10, 22, 12, 0, 0))
    after = weekly.next_time(Time.utc(2026, 10, 29, 12, 0, 0))

    expect(before.utc.iso8601).to eq("2026-10-23T02:00:00Z") # 03:00 BST
    expect(after.utc.iso8601).to eq("2026-10-30T03:00:00Z") # 03:00 GMT
  end

  it "builds valid Solid Queue recurring tasks for production schedules" do
    application_job_tasks("production").each do |key, options|
      task = SolidQueue::RecurringTask.from_configuration(
        key,
        **options.symbolize_keys.merge(static: true),
      )

      expect(task).to be_valid, -> { "#{key}: #{task.errors.full_messages.join(', ')}" }
    end
  end

  it "passes Solid Queue configuration check for the test environment" do
    configuration = SolidQueue::Configuration.new

    expect(configuration.check).to be(true), -> { configuration.errors.full_messages.join(", ") }
  end
end

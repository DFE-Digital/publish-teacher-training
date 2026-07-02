# frozen_string_literal: true

require "rails_helper"
require "rake"

describe "schools_backfill:run" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  subject(:run_task) { Rake::Task["schools_backfill:run"].invoke(*task_args) }

  let(:task_args) { [] }

  before { Rake::Task["schools_backfill:run"].reenable }

  it "invokes DataHub::SchoolsBackfill::Executor and prints both summaries" do
    executor = instance_double(DataHub::SchoolsBackfill::Executor)
    fake_summary = instance_double(
      DataHub::SchoolsBackfillProcessSummary,
      short_summary: { "provider_schools_inserted" => 0 },
      full_summary: { "skipped_sites_csv_path" => "tmp/foo.csv" },
    )

    allow(RecruitmentCycle).to receive(:pluck).with(:year).and_return(%w[2026 2025])
    allow(DataHub::SchoolsBackfill::Executor)
      .to receive(:new)
      .with(recruitment_cycle_years: %w[2026 2025])
      .and_return(executor)
    allow(executor).to receive(:execute).and_return(fake_summary)

    expect { run_task }.to output.to_stdout
    expect(executor).to have_received(:execute)
  end

  it "defaults to every recruitment cycle year" do
    executor = instance_double(DataHub::SchoolsBackfill::Executor)
    fake_summary = instance_double(
      DataHub::SchoolsBackfillProcessSummary,
      short_summary: {},
      full_summary: {},
    )

    allow(RecruitmentCycle).to receive(:pluck).with(:year).and_return(%w[2026 2025])
    allow(DataHub::SchoolsBackfill::Executor)
      .to receive(:new)
      .with(recruitment_cycle_years: %w[2026 2025])
      .and_return(executor)
    allow(executor).to receive(:execute).and_return(fake_summary)

    expect { run_task }.to output.to_stdout
  end

  context "with recruitment cycle years as rake arguments" do
    let(:task_args) { %w[2026 2025] }

    it "passes the years to the executor" do
      executor = instance_double(DataHub::SchoolsBackfill::Executor)
      fake_summary = instance_double(
        DataHub::SchoolsBackfillProcessSummary,
        short_summary: {},
        full_summary: {},
      )

      allow(DataHub::SchoolsBackfill::Executor)
        .to receive(:new)
        .with(recruitment_cycle_years: %w[2026 2025])
        .and_return(executor)
      allow(executor).to receive(:execute).and_return(fake_summary)

      expect { run_task }.to output.to_stdout
    end
  end
end

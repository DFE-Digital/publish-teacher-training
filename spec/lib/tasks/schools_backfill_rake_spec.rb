# frozen_string_literal: true

require "rails_helper"
require "rake"

describe "schools_backfill:run" do
  subject(:invoke_task) { Rake::Task["schools_backfill:run"].reenable && Rake::Task["schools_backfill:run"].invoke }

  before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  it "invokes DataHub::SchoolsBackfill::Executor and prints both summaries" do
    executor = instance_double(DataHub::SchoolsBackfill::Executor)
    fake_summary = instance_double(
      DataHub::SchoolsBackfillProcessSummary,
      short_summary: { "provider_schools_inserted" => 0 },
      full_summary: { "skipped_sites_csv_path" => "tmp/foo.csv" },
    )

    allow(DataHub::SchoolsBackfill::Executor).to receive(:new).and_return(executor)
    allow(executor).to receive(:execute).and_return(fake_summary)

    expect { invoke_task }.to output.to_stdout
    expect(executor).to have_received(:execute)
  end
end

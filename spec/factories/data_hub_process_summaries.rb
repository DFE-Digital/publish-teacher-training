FactoryBot.define do
  factory :process_summary, class: "DataHub::ProcessSummary" do
    type { "DataHub::SchoolsBackfillProcessSummary" }
    status { "started" }
    started_at { Time.current }
    finished_at { nil }
    short_summary { { "fake" => "summary" } }
    full_summary  { { "fake" => "full_summary" } }

    factory :schools_backfill_process_summary, class: "DataHub::SchoolsBackfillProcessSummary"
  end
end

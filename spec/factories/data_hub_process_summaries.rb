FactoryBot.define do
  factory :process_summary, class: "DataHub::ProcessSummary" do
    type { "DataHub::RegisterSchoolImportSummary" }
    status { "started" }
    started_at { Time.current }
    finished_at { nil }
    short_summary { { "fake" => "summary" } }
    full_summary  { { "fake" => "full_summary" } }

    factory :register_school_import_summary, class: "DataHub::RegisterSchoolImportSummary"
  end
end

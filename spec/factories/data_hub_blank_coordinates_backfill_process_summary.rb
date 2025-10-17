# frozen_string_literal: true

FactoryBot.define do
  factory :blank_coordinates_backfill_process_summary, class: "DataHub::BlankCoordinatesBackfillProcessSummary" do
    type { "DataHub::BlankCoordinatesBackfillProcessSummary" }
    status { "started" }
    started_at { Time.current }
    short_summary { {} }
    full_summary { {} }
  end
end

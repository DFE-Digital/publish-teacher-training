# frozen_string_literal: true

FactoryBot.define do
  factory :rollover_process_summary, class: "DataHub::RolloverProcessSummary" do
    type { "DataHub::RolloverProcessSummary" }
    status { "started" }
    started_at { Time.current }
    short_summary { {} }
    full_summary { {} }

    trait :finished do
      status { "finished" }
      finished_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      finished_at { Time.current }
    end

    trait :with_timeout do
      finished
      full_summary do
        {
          "providers_processed" => [],
          "errors" => [],
          "monitoring_timeout" => {
            "total_attempts" => 5,
            "final_processed_count" => 3,
            "expected_total" => 5,
            "timeout_at" => Time.current.iso8601,
            "warning" => "Monitoring stopped due to timeout. Some jobs may still be running.",
          },
        }
      end
    end

    trait :with_results do
      short_summary do
        {
          "total_providers" => 5,
          "providers_rolled_over" => 3,
          "providers_skipped" => 1,
          "providers_errored" => 1,
          "total_courses_rolled_over" => 10,
          "total_sites_rolled_over" => 8,
          "total_study_sites_rolled_over" => 6,
          "total_partnerships_rolled_over" => 2,
        }
      end

      full_summary do
        {
          "providers_processed" => [
            {
              "provider_code" => "ABC",
              "status" => "rolled_over",
              "timestamp" => Time.current.iso8601,
              "courses_count" => 5,
              "sites_count" => 3,
            },
          ],
          "errors" => [
            {
              "provider_code" => "ERR",
              "error_class" => "StandardError",
              "error_message" => "Something went wrong",
              "timestamp" => Time.current.iso8601,
            },
          ],
          "rollover_started_at" => Time.current.iso8601,
        }
      end
    end
  end

  factory :data_hub_rollover_process_summary, class: "DataHub::RolloverProcessSummary" do
    type { "DataHub::RolloverProcessSummary" }
    status { "started" }
    started_at { Time.current }
    short_summary { {} }
    full_summary { {} }
  end
end

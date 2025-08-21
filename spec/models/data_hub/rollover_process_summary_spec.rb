# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::RolloverProcessSummary, type: :model do
  let(:process_summary) { create(:rollover_process_summary) }

  describe "#initialize_summary!" do
    it "initializes with correct structure" do
      process_summary.initialize_summary!

      expect(process_summary.short_summary).to include(
        "total_providers" => 0,
        "providers_rolled_over" => 0,
        "providers_skipped" => 0,
        "providers_errored" => 0,
      )

      expect(process_summary.full_summary).to include(
        "providers_processed" => [],
        "errors" => [],
      )
    end
  end

  describe "#set_total_providers" do
    before { process_summary.initialize_summary! }

    it "updates total providers count" do
      process_summary.set_total_providers(10)

      expect(process_summary.short_summary["total_providers"]).to eq(10)
    end
  end

  describe "#completion_percentage" do
    before do
      process_summary.initialize_summary!
      process_summary.set_total_providers(10)
    end

    it "calculates correct percentage" do
      process_summary.add_provider_result(provider_code: "ABC", status: :rolled_over, details: {})
      process_summary.add_provider_result(provider_code: "DEF", status: :skipped, details: {})

      expect(process_summary.completion_percentage).to eq(20.0)
    end

    it "returns 0 when no providers" do
      process_summary.set_total_providers(0)

      expect(process_summary.completion_percentage).to eq(0)
    end
  end

  describe "#total_processed" do
    before { process_summary.initialize_summary! }

    it "sums all processed providers" do
      process_summary.add_provider_result(provider_code: "ABC", status: :rolled_over, details: {})
      process_summary.add_provider_result(provider_code: "DEF", status: :skipped, details: {})
      process_summary.add_provider_result(provider_code: "GHI", status: :errored, details: {})

      expect(process_summary.total_processed).to eq(3)
    end
  end

  describe "#eligible_not_rolled_over_details" do
    let(:current_cycle) { RecruitmentCycle.current }
    let(:target_cycle) { RecruitmentCycle.next || create(:recruitment_cycle, :next) }
    let(:process_summary) { create(:rollover_process_summary) }

    let!(:eligible_provider_one) { create(:provider, courses: [build(:course, :published)], provider_code: "ABC", recruitment_cycle: current_cycle) }
    let!(:eligible_provider_two) { create(:provider, courses: [build(:course, :published)], provider_code: "DEF", recruitment_cycle: current_cycle) }
    let!(:eligible_provider_three) { create(:provider, courses: [build(:course, :published)], provider_code: "GHI", recruitment_cycle: current_cycle) }

    let!(:rolled_over_provider) { create(:provider, provider_code: "ABC", recruitment_cycle: target_cycle) }

    before do
      process_summary.initialize_summary!

      process_summary.add_provider_result(
        provider_code: "ABC",
        status: :rolled_over,
        details: { courses_count: 2, sites_count: 1, study_sites_count: 0, partnerships_count: 0 },
      )

      process_summary.add_provider_result(
        provider_code: "DEF",
        status: :skipped,
        details: { reason: "Provider not rollable" },
      )

      process_summary.add_provider_result(
        provider_code: "GHI",
        status: :errored,
        details: { error_class: "StandardError", error_message: "Something went wrong" },
      )
    end

    it "returns entries for providers that are eligible but not rolled over" do
      result = process_summary.eligible_not_rolled_over_details(target_cycle: target_cycle)

      expect(result.size).to eq(2)

      provider_codes = result.map { |entry| entry["provider_code"] }
      expect(provider_codes).to contain_exactly("DEF", "GHI")

      expect(provider_codes).not_to include("ABC")
    end

    it "returns full summary entries with all details" do
      result = process_summary.eligible_not_rolled_over_details(target_cycle: target_cycle)

      skipped_entry = result.find { |entry| entry["provider_code"] == "DEF" }
      expect(skipped_entry).to include(
        "provider_code" => "DEF",
        "status" => "skipped",
        "reason" => "Provider not rollable",
      )
      expect(skipped_entry["timestamp"]).to be_present

      errored_entry = result.find { |entry| entry["provider_code"] == "GHI" }
      expect(errored_entry).to include(
        "provider_code" => "GHI",
        "status" => "errored",
        "error_class" => "StandardError",
        "error_message" => "Something went wrong",
      )
      expect(errored_entry["timestamp"]).to be_present
    end

    it "returns empty array when all eligible providers are rolled over" do
      create(:provider, provider_code: "DEF", recruitment_cycle: target_cycle)
      create(:provider, provider_code: "GHI", recruitment_cycle: target_cycle)

      result = process_summary.eligible_not_rolled_over_details(target_cycle: target_cycle)

      expect(result).to be_empty
    end

    it "returns empty array when no providers are processed" do
      empty_summary = create(:rollover_process_summary)
      empty_summary.initialize_summary!

      result = empty_summary.eligible_not_rolled_over_details(target_cycle: target_cycle)

      expect(result).to be_empty
    end

    context "when provider is eligible but not in processed list" do
      let!(:unprocessed_provider) do
        create(
          :provider,
          courses: [build(:course, :published)],
          provider_code: "XYZ",
          recruitment_cycle: current_cycle,
        )
      end

      it "does not include providers that were never processed" do
        result = process_summary.eligible_not_rolled_over_details(target_cycle: target_cycle)

        provider_codes = result.map { |entry| entry["provider_code"] }
        expect(provider_codes).not_to include("XYZ")
      end
    end

    it "handles providers with mixed statuses correctly" do
      result = process_summary.eligible_not_rolled_over_details(target_cycle: target_cycle)

      statuses = result.map { |entry| entry["status"] }
      expect(statuses).to contain_exactly("skipped", "errored")
      expect(statuses).not_to include("rolled_over")
    end
  end

  describe "#add_batch_enqueue_result" do
    let(:process_summary) { create(:rollover_process_summary) }
    let(:codes_batch_one) { %w[A B C] }
    let(:codes_batch_two) { %w[D E] }
    let(:timestamp_one)   { Time.current.iso8601 }
    let(:timestamp_two)   { (Time.current + 1.minute).iso8601 }

    before do
      process_summary.initialize_summary!

      travel_to Time.utc(2025, 8, 21, 12, 11, 18) do
        @timestamp_one = Time.current.iso8601
        process_summary.add_batch_enqueue_result(provider_codes: codes_batch_one)
      end

      travel_to Time.utc(2025, 8, 21, 12, 12, 18) do
        @timestamp_two = Time.current.iso8601
        process_summary.add_batch_enqueue_result(provider_codes: codes_batch_two)
      end
    end

    it "increments providers_enqueued counter correctly" do
      expect(process_summary.short_summary["providers_enqueued"]).to eq(5)
    end

    it "appends batch entries to full_summary with timestamps and codes" do
      batches = process_summary.full_summary["batches"]
      expect(batches.size).to eq(2)

      expect(batches[0].symbolize_keys).to include(
        timestamp: @timestamp_one,
        provider_codes: codes_batch_one,
      )
      expect(batches[1].symbolize_keys).to include(
        timestamp: @timestamp_two,
        provider_codes: codes_batch_two,
      )
    end

    it "persists the updated short_summary and full_summary" do
      reloaded = described_class.find(process_summary.id)
      expect(reloaded.short_summary["providers_enqueued"]).to eq(5)
      expect(
        reloaded.full_summary["batches"].map { |b| b["provider_codes"] },
      ).to contain_exactly(codes_batch_one, codes_batch_two)
    end
  end
end

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
end

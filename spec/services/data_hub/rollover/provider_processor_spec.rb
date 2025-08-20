# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::Rollover::ProviderProcessor, type: :service do
  let(:current_cycle) { RecruitmentCycle.current }
  let(:next_cycle) { RecruitmentCycle.next || create(:recruitment_cycle, :next) }
  let(:provider) { create(:provider, :accredited_provider, provider_code: "ABC", recruitment_cycle: current_cycle) }
  let(:process_summary) { create(:rollover_process_summary) }

  before do
    process_summary.initialize_summary!
  end

  describe ".process" do
    context "with a rollable provider" do
      let!(:course) { create(:course, :published, provider: provider) }
      let!(:site) { create(:site, provider: provider) }
      let!(:study_site) { create(:site, :study_site, provider: provider) }

      # Mock successful rollover result
      let(:successful_rollover_result) do
        {
          providers: 1,
          courses: 1,
          sites: 1,
          study_sites: 1,
          partnerships: 0,
          courses_failed: [],
          courses_skipped: [],
          study_sites_skipped: [],
          duration_seconds: 35.5,
        }
      end

      before do
        allow(RolloverProviderService).to receive(:call).and_return(successful_rollover_result)
        described_class.process("ABC", next_cycle.id, process_summary.id)
        process_summary.reload
      end

      it "successfully rolls over the provider" do
        expect(process_summary.short_summary["providers_rolled_over"]).to eq(1)
      end

      it "tracks course rollover count" do
        expect(process_summary.short_summary["total_courses_rolled_over"]).to eq(1)
      end

      it "tracks site rollover counts" do
        expect(process_summary.short_summary["total_sites_rolled_over"]).to eq(1)
        expect(process_summary.short_summary["total_study_sites_rolled_over"]).to eq(1)
      end

      it "records detailed provider information" do
        provider_info = process_summary.full_summary["providers_processed"].first

        expect(provider_info).to include(
          "provider_code" => "ABC",
          "status" => "rolled_over",
          "courses_count" => 1,
          "sites_count" => 1,
          "study_sites_count" => 1,
          "duration_seconds" => 35.5,
        )
      end
    end

    context "when provider already exists in target cycle" do
      let!(:existing_provider) { create(:provider, provider_code: "ABC", recruitment_cycle: next_cycle) }

      let(:skipped_rollover_result) do
        {
          providers: 0,
          courses: 0,
          sites: 0,
          study_sites: 0,
          partnerships: 0,
          courses_failed: [],
          courses_skipped: [],
          study_sites_skipped: [],
          duration_seconds: 1.2,
        }
      end

      it "skips the provider" do
        allow(RolloverProviderService).to receive(:call).and_return(skipped_rollover_result)

        provider # ensure provider exists in current cycle
        described_class.process("ABC", next_cycle.id, process_summary.id)

        process_summary.reload

        expect(process_summary.short_summary["providers_skipped"]).to eq(1)
        expect(process_summary.short_summary["providers_rolled_over"]).to eq(0)
      end
    end

    context "when provider does not exist" do
      let(:nonexistent_rollover_result) do
        {
          providers: 0,
          courses: 0,
          sites: 0,
          study_sites: 0,
          partnerships: 0,
          courses_failed: [],
          courses_skipped: [],
          study_sites_skipped: [],
          duration_seconds: 0.1,
        }
      end

      it "skips non-existent provider" do
        allow(RolloverProviderService).to receive(:call).and_return(nonexistent_rollover_result)

        described_class.process("NONEXISTENT", next_cycle.id, process_summary.id)

        process_summary.reload
        expect(process_summary.short_summary["providers_skipped"]).to eq(1)
      end
    end

    context "when rollover fails" do
      before do
        create(:course, :published, provider: provider)
        allow(RolloverProviderService).to receive(:call).and_raise(StandardError, "Something went wrong")
      end

      it "records the error without re-raising" do
        expect {
          described_class.process("ABC", next_cycle.id, process_summary.id)
        }.not_to raise_error

        process_summary.reload
        expect(process_summary.short_summary["providers_errored"]).to eq(1)

        error_info = process_summary.full_summary["errors"].first
        expect(error_info["error_message"]).to eq("Something went wrong")
      end
    end
  end
end

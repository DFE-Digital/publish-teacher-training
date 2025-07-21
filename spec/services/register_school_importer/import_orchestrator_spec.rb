require "rails_helper"

RSpec.describe RegisterSchoolImporter::ImportOrchestrator do
  subject(:orchestrator) do
    described_class.new(
      recruitment_cycle:,
      csv_path:,
      school_creator_class:,
    )
  end

  let(:recruitment_cycle) { build_stubbed(:recruitment_cycle) }
  let(:csv_path) { "dummy/path.csv" }
  let(:school_creator_class) { double("SchoolCreator") }
  let(:short_summary) { { "schools_added_count" => 2 } }
  let(:full_summary)  { { "meta" => short_summary, "groups" => [] } }

  describe "#run!" do
    context "when the import completes successfully" do
      let(:summary_double) do
        instance_double(RegisterSchoolImporter::ImportSummary, meta: short_summary, full_summary: full_summary)
      end

      before do
        allow(RegisterSchoolImporter::Importer).to receive(:new).and_return(
          instance_double(RegisterSchoolImporter::Importer, call: summary_double),
        )
      end

      it "creates a RegisterSchoolImportSummary with status 'finished'" do
        expect {
          orchestrator.run!
        }.to change(DataHub::RegisterSchoolImportSummary, :count).by(1)

        record = DataHub::RegisterSchoolImportSummary.order(:created_at).last

        expect(record.status).to eq("finished")
        expect(record.started_at).to be_present
        expect(record.finished_at).to be_present
        expect(record.short_summary).to eq(short_summary)
        expect(record.full_summary).to eq(full_summary)
      end
    end

    context "when the import raises an error" do
      let(:error) { StandardError.new("Simulated Error") }

      before do
        allow(RegisterSchoolImporter::Importer).to receive(:new).and_raise(error)
      end

      it "creates a failed RegisterSchoolImportSummary with error info in short_summary" do
        expect {
          begin
            orchestrator.run!
          rescue StandardError => _e
            # suppress in spec output
          end
        }.to change(DataHub::RegisterSchoolImportSummary, :count).by(1)

        record = DataHub::RegisterSchoolImportSummary.order(:created_at).last

        expect(record.status).to eq("failed")
        expect(record.started_at).to be_present
        expect(record.finished_at).to be_present

        expect(record.short_summary).to include(
          "error_class" => "StandardError",
          "error_message" => "Simulated Error",
        )

        expect(record.short_summary["backtrace"]).to be_an(Array)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataHub::CourseNamingChange::Runner do
  subject(:runner) do
    described_class.new(
      csv_path: csv_file.path,
      recruitment_cycle:,
      dry_run: dry_run,
      output: output,
      absolute_warning_threshold: absolute_threshold,
      percentage_warning_threshold: percentage_threshold,
    )
  end

  let(:recruitment_cycle) { create(:recruitment_cycle) }
  let(:provider) { create(:provider, recruitment_cycle:) }
  let!(:course_a) { create(:course, provider:, name: "Original name") }
  let!(:course_b) { create(:course, provider:, name: "Original name") }
  let(:other_course_name) { "Other name" }
  let!(:other_course) { create(:course, name: other_course_name) }
  let(:dry_run) { true }
  let(:output) { StringIO.new }
  let(:absolute_threshold) { described_class::DEFAULT_ABSOLUTE_WARNING_THRESHOLD }
  let(:percentage_threshold) { described_class::DEFAULT_PERCENTAGE_WARNING_THRESHOLD }
  let(:csv_file) { Tempfile.new(["course_names", ".csv"]) }
  let(:summary_scope) { DataHub::CourseNamingChangeSummary }
  let(:csv_content) do
    <<~CSV
      course name,tad subject,Count,replacement name
      Original name,ignored,2,Renamed course
    CSV
  end

  before do
    csv_file.rewind
    csv_file.truncate(0)
    csv_file.binmode
    csv_file.write(csv_content)
    csv_file.flush
    csv_file.rewind
    summary_scope.delete_all
  end

  after do
    csv_file.close
    csv_file.unlink
  end

  describe "#call" do
    it "produces a summary report and leaves courses unchanged in dry run" do
      report = nil

      expect { report = runner.call }.to change(summary_scope, :count).by(1)

      expect(report.dry_run?).to be(true)
      expect(report.processed_rows).to eq(1)
      expect(report.total_actual).to eq(2)
      expect(report.total_expected).to eq(2)
      expect(report.flagged_rows).to be_empty
      expect(course_a.reload.name).to eq("Original name")
      expect(course_b.reload.name).to eq("Original name")
      expect(output.string).to include("[DRY RUN]")
      expect(output.string).to include("processed_rows=1")

      summary = summary_scope.last
      expect(summary).to be_finished
      expect(summary.short_summary).to include(
        "dry_run" => true,
        "processed_rows" => 1,
        "total_actual" => 2,
        "total_expected" => 2,
        "warnings" => 0,
      )
      expect(summary.full_summary["rows"].size).to eq(1)
    end

    context "when applying changes" do
      let(:dry_run) { false }

      it "updates all matching courses in a transaction" do
        expect { runner.call }.to change(summary_scope, :count).by(1)

        expect(course_a.reload.name).to eq("Renamed course")
        expect(course_b.reload.name).to eq("Renamed course")
        expect(other_course.reload.name).to eq(other_course_name)
        expect(output.string).to include("[APPLY]")

        summary = summary_scope.last
        expect(summary).to be_finished
        expect(summary.short_summary["dry_run"]).to be(false)
        expect(summary.short_summary["total_actual"]).to eq(2)
      end
    end

    context "when the actual count differs significantly" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          Original name,ignored,20,Renamed course
        CSV
      end

      it "flags the row" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)

        expect(report.flagged_rows.size).to eq(1)
        flagged_row = report.flagged_rows.first
        expect(flagged_row.line_number).to eq(2)
        expect(flagged_row.warning?).to be(true)
        expect(flagged_row.warning_reason).to include("Expected 20")
        expect(output.string).to include("WARNING")

        summary = summary_scope.last
        expect(summary.short_summary["warnings"]).to eq(1)
        expect(summary.full_summary["flagged_rows"]).to include(2)
      end
    end

    context "with alternate replacement column name" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement
          Original name,ignored,2,Renamed course
        CSV
      end

      it "supports the alternate column heading" do
        expect { runner.call }.not_to raise_error
      end
    end

    context "when the row contains invalid UTF-8 bytes" do
      let(:csv_content) do
        header = "course name,tad subject,Count,replacement name\n"
        row = "Original name,ignored,2,Renamed course".dup.force_encoding("ASCII-8BIT")
        row << "\xC3".b
        "#{header}#{row}\n".force_encoding("ASCII-8BIT")
      end

      it "sanitises invalid characters before processing" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)
        processed_row = report.rows.first

        expect(processed_row.replacement_name).to eq("Renamed course")
        expect(report.flagged_rows).to be_empty
        expect(output.string).to include("Renamed course")

        summary = summary_scope.last
        expect(summary.short_summary["processed_rows"]).to eq(1)
      end
    end

    context "when the expected count column is blank" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          Original name,ignored,,Renamed course
        CSV
      end

      it "records the row without warnings" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)
        processed_row = report.rows.first

        expect(processed_row.expected_count).to be_nil
        expect(processed_row.difference).to be_nil
        expect(report.flagged_rows).to be_empty

        summary = summary_scope.last
        expect(summary.short_summary["warnings"]).to eq(0)
      end
    end

    context "when course name is missing" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          ,ignored,2,Renamed course
        CSV
      end

      it "raises a descriptive error" do
        expect { runner.call }.to raise_error(ArgumentError, /Row 2: course name is blank/)

        expect(summary_scope.count).to eq(1)
        summary = summary_scope.last
        expect(summary).to be_failed
        expect(summary.short_summary["error_class"]).to eq("ArgumentError")
      end
    end

    context "when replacement name is missing" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          Original name,ignored,2,
        CSV
      end

      it "skips the row and records a warning" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)
        processed_row = report.rows.first

        expect(processed_row.replacement_name).to eq("Original name")
        expect(processed_row.warning?).to be(true)
        expect(processed_row.warning_reason).to include("Replacement name missing")
        expect(output.string).to include("Replacement name missing")
        expect(course_a.reload.name).to eq("Original name")
        expect(course_b.reload.name).to eq("Original name")

        summary = summary_scope.last
        expect(summary.short_summary["warnings"]).to eq(1)
        expect(summary.full_summary["rows"].first["warning_reason"]).to include("Replacement name missing")
      end

      context "when applying changes" do
        let(:dry_run) { false }

        it "leaves courses unchanged and reports the warning" do
          report = nil

          expect { report = runner.call }.to change(summary_scope, :count).by(1)

          expect(report.flagged_rows.size).to eq(1)
          expect(course_a.reload.name).to eq("Original name")
          expect(course_b.reload.name).to eq("Original name")
          expect(output.string).to include("Replacement name missing")

          summary = summary_scope.last
          expect(summary.short_summary["dry_run"]).to be(false)
          expect(summary.short_summary["warnings"]).to eq(1)
        end
      end
    end

    context "when the expected count is not numeric" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          Original name,ignored,not-a-number,Renamed course
        CSV
      end

      it "raises a descriptive error" do
        expect { runner.call }.to raise_error(ArgumentError, /Unable to parse expected count 'not-a-number'/)

        expect(summary_scope.count).to eq(1)
        summary = summary_scope.last
        expect(summary).to be_failed
        expect(summary.short_summary["error_class"]).to eq("ArgumentError")
      end
    end

    context "when thresholds are tightened" do
      let(:absolute_threshold) { 1 }
      let(:percentage_threshold) { 0.0 }
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          Original name,ignored,1,Renamed course
        CSV
      end

      it "marks the row as a warning" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)

        expect(report.flagged_rows.size).to eq(1)
        expect(report.flagged_rows.first.warning_reason).to include("threshold 1")
        expect(output.string).to include("WARNING")

        summary = summary_scope.last
        expect(summary.short_summary["warnings"]).to eq(1)
      end
    end

    context "when the CSV contains an empty row" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          ,,,
          Original name,ignored,2,Renamed course
        CSV
      end

      it "skips the empty row" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)

        expect(report.processed_rows).to eq(1)
        expect(output.string.scan(/line=/).size).to eq(1)

        summary = summary_scope.last
        expect(summary.short_summary["processed_rows"]).to eq(1)
      end
    end

    context "when no courses match the given name" do
      let(:csv_content) do
        <<~CSV
          course name,tad subject,Count,replacement name
          Non-existent course,ignored,0,Renamed course
        CSV
      end

      it "logs the absence of matches" do
        report = nil

        expect { report = runner.call }.to change(summary_scope, :count).by(1)
        processed_row = report.rows.first

        expect(processed_row.actual_count).to eq(0)
        expect(report.flagged_rows).to be_empty
        expect(output.string).to include("identifiers=none")

        summary = summary_scope.last
        expect(summary.short_summary["total_actual"]).to eq(0)
      end
    end
  end

  describe ".new" do
    let(:output) { StringIO.new }

    it "raises when the csv path is missing" do
      expect {
        described_class.new(
          csv_path: nil,
          recruitment_cycle:,
          dry_run: true,
        )
      }.to raise_error(ArgumentError, /csv_path must be provided/)
    end

    it "raises when the csv file does not exist" do
      expect {
        described_class.new(
          csv_path: "not-real.csv",
          recruitment_cycle:,
          dry_run: true,
        )
      }.to raise_error(ArgumentError, /CSV file not found/)
    end

    it "raises when recruitment cycle is missing" do
      Tempfile.create(["empty", ".csv"]) do |file|
        expect {
          described_class.new(
            csv_path: file.path,
            recruitment_cycle: nil,
            dry_run: true,
          )
        }.to raise_error(ArgumentError, /recruitment_cycle must be provided/)
      end
    end
  end
end

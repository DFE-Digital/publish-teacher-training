require "rails_helper"

RSpec.describe DataHub::RegisterSchoolImporter::CLI do
  describe "#validate!" do
    context "when both CSV_PATH and YEAR are present" do
      let(:env) { { "CSV_PATH" => "/tmp/test.csv", "YEAR" => "2025" } }

      it "does not raise an error" do
        cli = described_class.new(environment: env)
        expect { cli.validate! }.not_to raise_error
      end
    end

    context "when CSV_PATH is missing" do
      let(:env) { { "YEAR" => "2025" } }

      it "raises an ArgumentError" do
        cli = described_class.new(environment: env)
        expect { cli.validate! }.to raise_error(ArgumentError)
      end
    end

    context "when YEAR is missing" do
      let(:env) { { "CSV_PATH" => "/tmp/test.csv" } }

      it "raises an ArgumentError" do
        cli = described_class.new(environment: env)
        expect { cli.validate! }.to raise_error(ArgumentError)
      end
    end

    context "when both CSV_PATH and YEAR are missing" do
      let(:env) { {} }

      it "raises an ArgumentError" do
        cli = described_class.new(environment: env)
        expect { cli.validate! }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#recruitment_cycle" do
    let!(:recruitment_cycle) { RecruitmentCycle.current }

    context "when the recruitment cycle exists" do
      let(:env) { { "CSV_PATH" => "/tmp/csv.csv", "YEAR" => recruitment_cycle.year } }

      it "returns the correct RecruitmentCycle" do
        cli = described_class.new(environment: env)
        expect(cli.recruitment_cycle).to eq(recruitment_cycle)
      end
    end

    context "when the recruitment cycle does not exist" do
      let(:env) { { "CSV_PATH" => "/tmp/csv.csv", "YEAR" => "2099" } }

      it "raises ActiveRecord::RecordNotFound" do
        cli = described_class.new(environment: env)
        expect { cli.recruitment_cycle }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

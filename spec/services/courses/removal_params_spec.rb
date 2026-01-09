require "rails_helper"

RSpec.describe Courses::RemovalParams do
  describe "#call" do
    context "with subject_code attribute" do
      it "clears subject_code and removes it from subjects array" do
        search_params = {
          subject_code: "00",
          subject_name: "Primary",
          subjects: %w[00 01 C1],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subject_code,
          current_value: "00",
          all_values: %w[00],
        ).call

        expect(removal_params).to eq({
          subject_code: nil,
          subject_name: nil,
          subjects: %w[01 C1],
        })
      end

      it "clears subject_code when it's the only value in subjects" do
        search_params = {
          subject_code: "C1",
          subject_name: "Biology",
          subjects: %w[C1],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subject_code,
          current_value: "C1",
          all_values: %w[C1],
        ).call

        expect(removal_params).to eq({
          subject_code: nil,
          subject_name: nil,
          subjects: nil,
        })
      end

      it "clears subject_code even when it's not in subjects array" do
        search_params = {
          subject_code: "00",
          subject_name: "Primary",
          subjects: %w[01 C1],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subject_code,
          current_value: "00",
          all_values: %w[00],
        ).call

        expect(removal_params).to eq({
          subject_code: nil,
          subject_name: nil,
          subjects: %w[01 C1],
        })
      end

      it "handles missing subjects array gracefully" do
        search_params = {
          subject_code: "F3",
          subject_name: "Physics",
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subject_code,
          current_value: "F3",
          all_values: %w[F3],
        ).call

        expect(removal_params).to eq({
          subject_code: nil,
          subject_name: nil,
          subjects: nil,
        })
      end
    end

    context "with subjects attribute" do
      it "removes subject from array without affecting subject_code when they don't match" do
        search_params = {
          subject_code: "00",
          subject_name: "Primary",
          subjects: %w[01 C1 08],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subjects,
          current_value: "C1",
          all_values: %w[01 C1 08],
        ).call

        expect(removal_params).to eq({
          subjects: %w[01 08],
        })
      end

      it "clears subject_code when removing matching subject" do
        search_params = {
          subject_code: "C1",
          subject_name: "Biology",
          subjects: %w[C1 08 F3],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subjects,
          current_value: "C1",
          all_values: %w[C1 08 F3],
        ).call

        expect(removal_params).to eq({
          subjects: %w[08 F3],
          subject_code: nil,
          subject_name: nil,
        })
      end

      it "clears both when removing last matching subject" do
        search_params = {
          subject_code: "01",
          subject_name: "Secondary with English",
          subjects: %w[01],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subjects,
          current_value: "01",
          all_values: %w[01],
        ).call

        expect(removal_params).to eq({
          subjects: nil,
          subject_code: nil,
          subject_name: nil,
        })
      end

      it "removes only the specified subject from array" do
        search_params = {
          subject_code: "00",
          subjects: %w[00 01 C1 08],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subjects,
          current_value: "08",
          all_values: %w[00 01 C1 08],
        ).call

        expect(removal_params).to eq({
          subjects: %w[00 01 C1],
        })
      end

      it "handles nil subject_code" do
        search_params = {
          subject_code: nil,
          subjects: %w[01 C1 08],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subjects,
          current_value: "C1",
          all_values: %w[01 C1 08],
        ).call

        expect(removal_params).to eq({
          subjects: %w[01 08],
        })
      end

      it "handles blank subject_code" do
        search_params = {
          subject_code: "",
          subjects: %w[01 C1],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :subjects,
          current_value: "01",
          all_values: %w[01 C1],
        ).call

        expect(removal_params).to eq({
          subjects: %w[C1],
        })
      end
    end

    context "with other attributes" do
      it "calculates default removal for non-subject attributes" do
        search_params = {
          funding: %w[fee salary apprenticeship],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :funding,
          current_value: "fee",
          all_values: %w[fee salary apprenticeship],
        ).call

        expect(removal_params).to eq({
          funding: %w[salary apprenticeship],
        })
      end

      it "returns nil for single value removal" do
        search_params = {
          level: "further_education",
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :level,
          current_value: "further_education",
          all_values: %w[further_education],
        ).call

        expect(removal_params).to eq({
          level: nil,
        })
      end

      it "handles empty remaining values" do
        search_params = {
          study_types: %w[full_time],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :study_types,
          current_value: "full_time",
          all_values: %w[full_time],
        ).call

        expect(removal_params).to eq({
          study_types: nil,
        })
      end

      it "handles multiple remaining values for other attributes" do
        search_params = {
          qualifications: %w[qts qts_with_pgce_or_pgde],
        }

        removal_params = described_class.new(
          search_params: search_params,
          attribute: :qualifications,
          current_value: "qts",
          all_values: %w[qts qts_with_pgce_or_pgde],
        ).call

        expect(removal_params).to eq({
          qualifications: %w[qts_with_pgce_or_pgde],
        })
      end
    end
  end
end

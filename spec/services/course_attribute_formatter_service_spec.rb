require "rails_helper"

RSpec.describe CourseAttributeFormatterService do
  subject { CourseAttributeFormatterService.call(name: name, value: value) }

  context "with an attribute that doesn't require formatting" do
    let(:name) { "name" }
    let(:value) { "course name" }

    it "is returned" do
      expect(subject).to eq(value)
    end
  end

  context "with an age range" do
    let(:name) { "age_range_in_years" }
    let(:value) { "10_to_14" }

    it "removes underscores" do
      expect(subject).to eq("10 to 14")
    end
  end

  context "with a qualification" do
    let(:name) { "qualification" }

    context "qts" do
      let(:value) { "qts" }
      let(:expected_value) { "QTS" }

      it { is_expected.to eq(expected_value) }
    end

    context "pgce_with_qts" do
      let(:value) { "pgce_with_qts" }
      let(:expected_value) { "PGCE with QTS" }

      it { is_expected.to eq(expected_value) }
    end

    context "pgce" do
      let(:value) { "pgce" }
      let(:expected_value) { "PGCE" }

      it { is_expected.to eq(expected_value) }
    end

    context "pgde_with_qts" do
      let(:value) { "pgde_with_qts" }
      let(:expected_value) { "PGDE with QTS" }

      it { is_expected.to eq(expected_value) }
    end

    context "pgde" do
      let(:value) { "pgde" }
      let(:expected_value) { "PGDE" }

      it { is_expected.to eq(expected_value) }
    end
  end

  context "with a study mode" do
    let(:name) { "study_mode" }

    context "full_time" do
      let(:value) { "full_time" }
      let(:expected_value) { "full time" }

      it { is_expected.to eq(expected_value) }
    end

    context "full_time_or_part_time" do
      let(:value) { "full_time_or_part_time" }
      let(:expected_value) { "full time or part time" }

      it { is_expected.to eq(expected_value) }
    end

    context "part_time" do
      let(:value) { "part_time" }
      let(:expected_value) { "part time" }

      it { is_expected.to eq(expected_value) }
    end
  end

  shared_examples_for "entry requirements" do
    context "must_have_qualification_at_application_time" do
      let(:value) { "must_have_qualification_at_application_time" }
      let(:expected_value) { "Must have the GCSE" }

      it { is_expected.to eq(expected_value) }
    end

    context "equivalence_test" do
      let(:value) { "equivalence_test" }
      let(:expected_value) { "Equivalency test" }

      it { is_expected.to eq(expected_value) }
    end

    context "expect_to_achieve_before_training_begins" do
      let(:value) { "expect_to_achieve_before_training_begins" }
      let(:expected_value) { "Taking the GCSE" }

      it { is_expected.to eq(expected_value) }
    end

    context "not_required" do
      let(:value) { "not_required" }
      let(:expected_value) { "Not required" }

      it { is_expected.to eq(expected_value) }
    end
  end

  context "maths" do
    let(:name) { "maths" }

    it_behaves_like "entry requirements"
  end

  context "english" do
    let(:name) { "english" }

    it_behaves_like "entry requirements"
  end

  context "science" do
    let(:name) { "science" }

    it_behaves_like "entry requirements"
  end
end

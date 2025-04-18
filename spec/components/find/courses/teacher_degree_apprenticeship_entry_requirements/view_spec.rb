# frozen_string_literal: true

require "rails_helper"

describe Find::Courses::TeacherDegreeApprenticeshipEntryRequirements::View do
  let(:course) { build(:course) }
  let(:preview) { false }
  let(:result) { render_inline(described_class.new(course: course.decorate, preview:)) }

  context "when teacher degree apprenticeship course" do
    let(:course) do
      build(
        :course,
        :with_teacher_degree_apprenticeship,
        :with_a_level_requirements,
        :resulting_in_undergraduate_degree_with_qts,
        accept_gcse_equivalency: false,
        accept_pending_gcse: false,
        additional_a_level_equivalencies: "Some text about A level equivalencies",
      )
    end

    it "renders A levels and GCSEs only and ignores degrees" do
      expected_text = <<~TEXT
        Any subject - Grade A or above or equivalent qualification We’ll consider candidates with pending A levels. Equivalency tests We’ll consider candidates who need to take A level equivalency tests. Some text about A level equivalencies
      TEXT

      expect(result.text.gsub(/\r?\n/, " ").squeeze(" ").strip).to include(expected_text.strip)
    end
  end

  context "when not teacher degree apprenticeship course" do
    let(:course) do
      build(
        :course,
        :with_higher_education,
      )
    end

    it "renders nothing" do
      expect(result.text).to eq("")
    end
  end

  context "when preview and there are no A levels" do
    let(:preview) { true }
    let(:course) do
      build(
        :course,
        :with_teacher_degree_apprenticeship,
        :resulting_in_undergraduate_degree_with_qts,
        a_level_subject_requirements: [],
        accept_pending_a_level: nil,
        accept_a_level_equivalency: nil,
        additional_a_level_equivalencies: nil,
      )
    end

    it "renders the headings and enter A levels text" do
      expect(result.text.gsub(/\r?\n/, " ").squeeze(" ").strip).to eq(
        "Enter A levels and equivalency test requirements",
      )
    end
  end

  context "when not preview and there are no A levels" do
    let(:preview) { false }
    let(:course) do
      build(
        :course,
        :with_teacher_degree_apprenticeship,
        :resulting_in_undergraduate_degree_with_qts,
        a_level_subject_requirements: [],
        accept_pending_a_level: nil,
        accept_a_level_equivalency: nil,
        additional_a_level_equivalencies: nil,
      )
    end

    it "renders the headings" do
      expect(result.text.gsub(/\r?\n/, " ").squeeze(" ").strip).to eq("")
    end
  end
end

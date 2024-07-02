# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::TeacherDegreeApprenticeshipEntryRequirements::View do
  let(:course) { build(:course) }
  let(:result) { render_inline(described_class.new(course: course.decorate)) }

  context 'when teacher degree apprenticeship course' do
    let(:course) do
      build(
        :course,
        :with_teacher_degree_apprenticeship,
        :with_a_level_requirements,
        :resulting_in_undergraduate_degree_with_qts,
        accept_gcse_equivalency: false,
        accept_pending_gcse: false,
        additional_a_level_equivalencies: 'Some text about A level equivalencies'
      )
    end

    it 'renders A levels and GCSEs only and ignores degrees' do
      expected_text = <<~TEXT
        A levels Any subject - Grade A or above, or equivalent qualification We’ll consider candidates with pending A levels. We’ll consider candidates who need to take A level equivalency tests. Some text about A level equivalencies GCSEs
      TEXT

      expect(result.text.gsub(/\r?\n/, ' ').squeeze(' ').strip).to include(expected_text.strip)
    end
  end

  context 'when not teacher degree apprenticeship course' do
    let(:course) do
      build(
        :course,
        :with_higher_education
      )
    end

    it 'renders nothing' do
      expect(result.text).to eq('')
    end
  end
end

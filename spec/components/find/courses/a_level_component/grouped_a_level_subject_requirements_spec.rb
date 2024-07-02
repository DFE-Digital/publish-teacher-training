# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Find::Courses::ALevelComponent::GroupedALevelSubjectRequirements do
  subject(:grouped_a_level_subject_requirements) do
    described_class.new(course).to_a_level_equivalency_array
  end

  let(:course) { create(:course, a_level_subject_requirements:).decorate }
  let(:a_level_subject_requirements) { [] }

  describe '#to_a_level_equivalency_array' do
    context 'with up to 4 singular subjects' do
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_subject' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_stem_subject' },
          { 'uuid' => 'uuid-3', 'subject' => 'any_modern_foreign_language', 'minimum_grade_required' => 'A' },
          { 'uuid' => 'uuid-4', 'subject' => 'other_subject', 'other_subject' => 'Geography' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(
          [
            'Any subject',
            'Any STEM subject',
            'Any modern foreign language - Grade A or above',
            'Geography'
          ]
        )
      end
    end

    context 'when any stem subjects are the same' do
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_stem_subject' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_stem_subject' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(
          ['Any two STEM subjects']
        )
      end
    end

    context 'when any stem subjects and grade are the same' do
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_stem_subject', minimum_grade_required: 'B' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_stem_subject', minimum_grade_required: 'B' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(
          ['Any two STEM subjects - Grade B or above']
        )
      end
    end

    context 'when any modern foreign language subjects are the same' do
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_modern_foreign_language' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_modern_foreign_language' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(['Any two modern foreign languages'])
      end
    end

    context 'when any modern foreign language subjects are the same but grades are different' do
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'B' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(
          [
            'Any modern foreign language - Grade A or above',
            'Any modern foreign language - Grade B or above'
          ]
        )
      end
    end

    context 'when equivalency and any modern foreign language subjects are the same but grades are different' do
      let(:course) { create(:course, :with_a_level_requirements, a_level_subject_requirements:).decorate }

      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(
          [
            'Any two modern foreign languages - Grade A or above, or equivalent qualification'
          ]
        )
      end
    end

    context 'when any other subjects are the same' do
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'other_subject', 'other_subject' => 'Geography' },
          { 'uuid' => 'uuid-2', 'subject' => 'other_subject', 'other_subject' => 'Geography' }
        ]
      end

      it 'renders the correct content' do
        expect(grouped_a_level_subject_requirements).to eq(%w[Geography])
      end
    end

    context 'when duplicate with A level with equivalency tests' do
      let(:course) { create(:course, :with_a_level_requirements, a_level_subject_requirements:).decorate }
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' }
        ]
      end

      it 'renders the subject with equivalency' do
        expect(grouped_a_level_subject_requirements).to eq(
          [
            'Any two modern foreign languages - Grade A or above, or equivalent qualification'
          ]
        )
      end
    end

    context 'when duplicate with A level with equivalency tests without grade' do
      let(:course) { create(:course, :with_a_level_requirements, a_level_subject_requirements:).decorate }
      let(:a_level_subject_requirements) do
        [
          { 'uuid' => 'uuid-1', 'subject' => 'any_modern_foreign_language' },
          { 'uuid' => 'uuid-2', 'subject' => 'any_modern_foreign_language' }
        ]
      end

      it 'renders the subject with equivalency' do
        expect(grouped_a_level_subject_requirements).to eq(
          [
            'Any two modern foreign languages, or equivalent qualification'
          ]
        )
      end
    end

    context 'when considering candidates who need A level equivalency tests' do
      let(:course) { create(:course, :with_a_level_requirements).decorate }

      it 'renders the subject with equivalency' do
        expect(grouped_a_level_subject_requirements).to eq(
          [
            'Any subject - Grade A or above, or equivalent qualification'
          ]
        )
      end
    end
  end
end

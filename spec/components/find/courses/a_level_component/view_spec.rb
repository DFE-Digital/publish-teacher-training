# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Find::Courses::ALevelComponent::View, type: :component do
  subject(:result) { render_inline(described_class.new(course:)).text }

  let(:course) { create(:course, a_level_subject_requirements:).decorate }
  let(:a_level_subject_requirements) { [] }

  context 'with up to 4 singular subjects' do
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_subject' },
        { 'subject' => 'any_stem_subject' },
        { 'subject' => 'any_modern_foreign_language', 'minimum_grade_required' => 'A' },
        { 'subject' => 'other_subject', 'other_subject' => 'Geography' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include(
        'Any subject', 'Any STEM subject', 'Any modern foreign language - Grade A or above', 'Geography'
      )
    end
  end

  context 'when any stem subjects are the same' do
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_stem_subject' },
        { 'subject' => 'any_stem_subject' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include(
        'Any two STEM subjects'
      )
    end
  end

  context 'when any stem subjects and grade are the same' do
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_stem_subject', minimum_grade_required: 'B' },
        { 'subject' => 'any_stem_subject', minimum_grade_required: 'B' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include(
        'Any two STEM subjects - Grade B or above'
      )
    end
  end

  context 'when any modern foreign language subjects are the same' do
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_modern_foreign_language' },
        { 'subject' => 'any_modern_foreign_language' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include('Any two modern foreign languages')
    end
  end

  context 'when any modern foreign language subjects are the same but grades are different' do
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' },
        { 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'B' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include(
        'Any modern foreign language - Grade A or above',
        'Any modern foreign language - Grade B or above'
      )
    end
  end

  context 'when equivalency and any modern foreign language subjects are the same but grades are different' do
    let(:course) { create(:course, :with_a_level_requirements, a_level_subject_requirements:).decorate }

    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' },
        { 'subject' => 'any_modern_foreign_language', minimum_grade_required: 'A' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include(
        'Any two modern foreign languages - Grade A or above, or equivalent qualification'
      )
    end
  end

  context 'when any other subjects are the same' do
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'other_subject', 'other_subject' => 'Geography' },
        { 'subject' => 'other_subject', 'other_subject' => 'Geography' }
      ]
    end

    it 'renders the correct content' do
      expect(result).to include(
        'Geography'
      )
    end
  end

  context 'when considering candidates with pending A levels' do
    let(:course) { create(:course, :with_a_level_requirements, accept_pending_a_level: true).decorate }

    it 'renders the correct content when pending A levels are considered' do
      expect(result).to include('We’ll consider candidates with pending A levels.')
    end
  end

  context 'when not considering candidates with pending A levels' do
    let(:course) { create(:course, :with_a_level_requirements, accept_pending_a_level: false).decorate }

    it 'renders the correct content when pending A levels are not considered' do
      expect(result).to include('We will not consider candidates with pending A levels.')
    end
  end

  context 'when considering candidates who need A level equivalency tests' do
    let(:course) { create(:course, :with_a_level_requirements).decorate }

    it 'renders the correct content when A level equivalency tests are considered' do
      expect(result).to include('We’ll consider candidates who need to take A level equivalency tests.')
    end

    it 'renders the subject with equivalency' do
      expect(result).to include('Any subject - Grade A or above, or equivalent qualification')
    end
  end

  context 'when not considering candidates who need A level equivalency tests' do
    let(:course) do
      create(
        :course,
        a_level_subject_requirements:,
        accept_a_level_equivalency: false
      ).decorate
    end
    let(:a_level_subject_requirements) do
      [
        { 'subject' => 'any_stem_subject' }
      ]
    end

    it 'renders the correct content when A level equivalency tests are not considered' do
      expect(result).to include('We will not consider candidates who need to take A level equivalency tests.')
    end
  end
end

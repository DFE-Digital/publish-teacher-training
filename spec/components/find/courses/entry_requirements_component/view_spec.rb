# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::EntryRequirementsComponent::View, type: :component do
  def then_i_should_see_the_ske_link
    expect(page).to have_link('subject knowledge enhancement (SKE) course.', href: 'https://getintoteaching.education.gov.uk/train-to-be-a-teacher/subject-knowledge-enhancement')
  end

  context 'when English is selected' do
    it 'renders correct message' do
      course = build(
        :course,
        subjects: [build(:secondary_subject, :english)]
      )
      result = render_inline(described_class.new(course: course.decorate))
      expect(result.text).to include('or you’ve not used your subject knowledge in a while, you may be asked to complete a')
      expect(result.text).to include('English')
      then_i_should_see_the_ske_link
    end
  end

  context 'when mathematics is selected' do
    it 'renders correct message' do
      course = build(
        :course,
        subjects: [build(:secondary_subject, :mathematics)]
      )
      result = render_inline(described_class.new(course: course.decorate))
      expect(result.text).to include('or you’ve not used your subject knowledge in a while, you may be asked to complete a')
      expect(result.text).to include('mathematics')
      then_i_should_see_the_ske_link
    end
  end

  context 'with multiple subject_knowledge_enhancement_subjects' do
    it 'renders correct message' do
      course = build(
        :course,
        subjects: [build(:secondary_subject, :german), build(:secondary_subject, :spanish)]
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include('or you’ve not used your subject knowledge in a while, you may be asked to complete a')
      then_i_should_see_the_ske_link
    end
  end

  context 'with a primary maths subject_knowledge_enhancement_subject' do
    it 'renders correct message' do
      course = build(
        :course,
        subjects: [build(:primary_subject, :primary_with_mathematics)]
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include('If you need to improve your primary mathematics knowledge, you may be asked to complete a')
      then_i_should_see_the_ske_link
    end
  end

  context 'when the provider accepts pending GCSEs' do
    it 'renders correct message' do
      course = build(
        :course,
        accept_pending_gcse: true
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'We’ll consider candidates with pending GCSEs'
      )
    end
  end

  context 'when the provider does NOT accept pending GCSEs' do
    it 'renders correct message' do
      course = build(
        :course,
        accept_pending_gcse: false
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'We will not consider candidates with pending GCSEs.'
      )
    end
  end

  context 'when the provider requires grade 4 and the course is primary' do
    it 'renders correct message' do
      course = build(
        :course,
        provider: build(:provider, provider_code: 'ABC'),
        level: 'primary'
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'Grade 4 (C) or above in English, maths and science, or equivalent qualification.'
      )
      expect(result.text).not_to include(
        "Your degree subject should be in #{course.name} or a similar subject. Otherwise you’ll need to prove your subject knowledge in some other way"
      )
    end
  end

  context 'when the provider requires grade 5 and the course is secondary' do
    it 'renders correct message' do
      raw_course = build(
        :course,
        provider: build(:provider, provider_code: 'U80'),
        level: 'secondary'
      )

      course = raw_course.decorate

      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'Grade 5 (C) or above in English and maths, or equivalent qualification.'
      )
      expect(result.text).to include(
        "Your degree subject should be in #{course.computed_subject_name_or_names} or a similar subject. Otherwise you’ll need to prove your subject knowledge in some other way"
      )
    end

    context 'when the campaign_name is set to engineers_teach_physics' do
      it 'renders correct message' do
        raw_course = build(
          :course,
          :engineers_teach_physics,
          :secondary,
          provider: build(:provider, provider_code: 'U80')
        )

        course = raw_course.decorate
        result = render_inline(described_class.new(course:))

        expect(result.text).to include(
          'Your degree subject should be in engineering, materials science or a related subject, otherwise you’ll need to prove your subject knowledge in some other way.'
        )
      end
    end

    context 'when the accrediting provider requires grade 5 and the course is secondary' do
      it 'renders correct message' do
        accrediting_provider = build(:provider, provider_code: 'U80')
        course = build(
          :course,
          provider: build(:provider),
          accrediting_provider:,
          level: 'secondary'
        )

        result = render_inline(described_class.new(course: course.decorate))

        expect(result.text).to include(
          'Grade 5 (C) or above in English and maths, or equivalent qualification.'
        )
      end
    end
  end

  context 'when the provider does not accept equivalent GCSE grades' do
    it 'renders correct message' do
      course = build(
        :course,
        accept_gcse_equivalency: false,
        accept_english_gcse_equivalency: false,
        accept_maths_gcse_equivalency: false,
        accept_science_gcse_equivalency: false
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'We will not consider candidates who need to take a GCSE equivalency test.'
      )
    end
  end

  context 'when the provider accepts equivalent GCSE grades for Maths and science' do
    it 'renders correct message' do
      course = build(
        :course,
        accept_gcse_equivalency: true,
        accept_english_gcse_equivalency: false,
        accept_maths_gcse_equivalency: true,
        accept_science_gcse_equivalency: true
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'We’ll consider candidates who need to take a GCSE equivalency test in maths or science'
      )
    end
  end

  context 'when the provider requires a 2:2 and specifies additional requirements' do
    it 'renders correct message' do
      course = build(
        :course,
        degree_grade: 'two_two',
        additional_degree_subject_requirements: true,
        degree_subject_requirements: 'Certificate must be printed on green paper.'
      )
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        '2:2 or above, or equivalent.'
      )
      expect(result.text).to include(
        'Certificate must be printed on green paper.'
      )
    end
  end
end

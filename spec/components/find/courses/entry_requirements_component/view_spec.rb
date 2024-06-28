# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::EntryRequirementsComponent::View, type: :component do
  let(:course) { build(:course, subjects:, accept_gcse_equivalency: false, accept_pending_gcse: false) }
  let(:subjects) { [build(:secondary_subject, subject_name)] }
  let(:result) { render_inline(described_class.new(course: course.decorate)) }
  let(:ske_text) { 'If you need to improve your subject knowledge, you may be asked to complete a' }
  let(:ske_url_name) { 'subject knowledge enhancement (SKE) course.' }
  let(:ske_url) { 'https://getintoteaching.education.gov.uk/train-to-be-a-teacher/subject-knowledge-enhancement' }

  context 'when physics is selected' do
    let(:subject_name) { :physics }

    it 'renders correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))
      expect(result).to have_link(ske_url_name, href: ske_url)
    end
  end

  context 'when mathematics is selected' do
    let(:subject_name) { :mathematics }

    it 'renders the correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))
      expect(result).to have_link(ske_url_name, href: ske_url)
    end
  end

  context 'with multiple subject_knowledge_enhancement_subjects' do
    let(:subjects) { [build(:secondary_subject, :german), build(:secondary_subject, :spanish)] }

    it 'renders correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))
      expect(result).to have_link(ske_url_name, href: ske_url)
    end
  end

  context 'with english as the second subject_knowledge_enhancement_subject' do
    let(:subjects) { [build(:secondary_subject, :mathematics), build(:secondary_subject, :english)] }

    it 'renders correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))
      expect(result).to have_link(ske_url_name, href: ske_url)
    end
  end

  context 'with a none subject_knowledge subject as the first subject and a subject_knowledge subject as the second' do
    let(:subjects) { [build(:secondary_subject, :art_and_design), build(:secondary_subject, :english)] }

    it 'does not render the ske message' do
      expect(result.text).not_to include(ske_text)
    end
  end

  context 'with a modern language subject' do
    let(:course_subject) { build(:secondary_subject, :modern_languages) }
    let(:subjects) { [course_subject, build(:modern_languages_subject, :french)] }

    it 'renders correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))
      expect(result).to have_link(ske_url_name, href: ske_url)
    end
  end

  context 'when the provider accepts pending GCSEs' do
    it 'renders correct message' do
      course = build(
        :course,
        accept_pending_gcse: true,
        accept_gcse_equivalency: false
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
        accept_pending_gcse: false,
        accept_gcse_equivalency: false
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
        accept_gcse_equivalency: false,
        accept_pending_gcse: false,
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
        accept_gcse_equivalency: false,
        accept_pending_gcse: false,
        provider: build(:provider, provider_code: 'I30'),
        level: 'secondary'
      )

      course = raw_course.decorate

      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'Grade 5 (C) or above in English and maths, or equivalent qualification.'
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
          'This Engineers teach physics course is designed for candidates who have a background in materials science and engineering. If your degree is in physics, please apply to our physics course.'
        )
      end
    end

    context 'when the accrediting provider requires grade 5 and the course is secondary' do
      it 'renders correct message' do
        accrediting_provider = build(:provider, provider_code: 'I30')
        course = build(
          :course,
          accept_gcse_equivalency: false,
          accept_pending_gcse: false,
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
        accept_pending_gcse: false,
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
        accept_pending_gcse: false,
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

  it 'includes the qualifications gain outside of UK section' do
    course = build(
      :course,
      degree_grade: 'two_two',
      additional_degree_subject_requirements: true,
      degree_subject_requirements: 'Certificate must be printed on green paper.'
    )
    render_inline(described_class.new(course: course.decorate))

    expect(page).to have_css('h3', text: 'Qualifications gained outside the UK')

    expect(page).to have_text('If you studied for your qualifications outside of the UK you should apply for a statement of comparability from UK European Network of Information Centres (UK ENIC). This will show us how your qualifications compare to UK qualifications.')

    expect(page).to have_link('Apply for a statement of comparability (opens in new tab)')
  end
end

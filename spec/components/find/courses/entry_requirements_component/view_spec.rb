# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::EntryRequirementsComponent::View, type: :component do
  let(:course) { build(:course, subjects:, accept_gcse_equivalency: false, accept_pending_gcse: false) }
  let(:subjects) { [build(:secondary_subject, subject_name)] }
  let(:result) { render_inline(described_class.new(course: course.decorate)) }
  let(:ske_text) { 'If you need to improve your subject knowledge, you may be asked to complete a' }
  let(:ske_url_name) { 'subject knowledge enhancement (SKE) course.' }
  let(:ske_url) { 'https://getintoteaching.education.gov.uk/train-to-be-a-teacher/subject-knowledge-enhancement' }

  context 'when teacher degree apprenticeship course' do
    let(:subject_name) { :physics }
    let(:course) do
      build(
        :course,
        :with_teacher_degree_apprenticeship,
        :with_a_level_requirements,
        :resulting_in_undergraduate_degree_with_qts,
        subjects:,
        accept_gcse_equivalency: false,
        accept_pending_gcse: false,
        provider: create(:provider, provider_code: 'I31') # Avoid provider_code I30
      )
    end

    it 'renders A levels and GCSEs only and ignores degrees' do
      expected_text = <<~TEXT.chomp
        Entry requirements A levels Any subject - Grade A or above or equivalent qualification We’ll consider candidates with pending A levels. Equivalency tests We’ll consider candidates who need to take A level equivalency tests. Some text GCSEs Grade 4 (C) in English, maths and science or above, or equivalent qualification We will not consider candidates with pending GCSEs. Equivalency tests We will not consider candidates who need to take a GCSE equivalency test.
      TEXT

      expect(result).to have_content(expected_text, normalize_ws: true)
    end
  end

  context 'when physics is selected' do
    let(:subject_name) { :physics }

    it 'renders correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))

      within('.govuk-details__summary') do
        expect(result).to have_link(ske_url_name, href: ske_url)
      end
    end
  end

  context 'when mathematics is selected' do
    let(:subject_name) { :mathematics }

    it 'renders the correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))

      within('.govuk-details__summary') do
        expect(result).to have_link(ske_url_name, href: ske_url)
      end
    end
  end

  context 'with multiple subject_knowledge_enhancement_subjects' do
    let(:subjects) { [build(:secondary_subject, :german), build(:secondary_subject, :spanish)] }

    it 'renders correct message' do
      expect(result.text).to include(ske_text)
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))

      within('.govuk-details__summary') do
        expect(result).to have_link(ske_url_name, href: ske_url)
      end
    end
  end

  context 'with english as the second subject_knowledge_enhancement_subject' do
    let(:subjects) { [build(:secondary_subject, :mathematics), build(:secondary_subject, :english)] }

    it 'renders correct message' do
      within('.govuk-details__summary') do
        expect(result.text).to include(ske_text)
      end
    end

    it 'renders the correct link' do
      render_inline(described_class.new(course: course.decorate))

      within('.govuk-details__summary') do
        expect(result).to have_link(ske_url_name, href: ske_url)
      end
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

      within('.govuk-details__summary') do
        expect(result).to have_link(ske_url_name, href: ske_url)
      end
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
        'Grade 4 (C) in English, maths and science'
      )
      expect(result.text).to include(
        'or above or equivalent qualification'
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
        'Grade 5 (C) in English and maths'
      )
      expect(result.text).to include(
        'or above, or equivalent qualification'
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
          'Grade 5 (C) in English and maths'
        )
        expect(result.text).to include(
          'or above, or equivalent qualification'
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
        '2:2 bachelor’s degree'
      )
      expect(result.text).to include(
        'or above or equivalent qualification'
      )
      expect(result.text).to include(
        'Certificate must be printed on green paper.'
      )
    end
  end

  context 'when course two_one' do
    it 'renders correct message' do
      course = build(:course, degree_grade: :two_one)
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        '2:1 bachelor’s degree',
        'or above or equivalent qualification'
      )
    end
  end

  context 'when course is third_class' do
    it 'renders correct message' do
      course = build(:course, degree_grade: :third_class)
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'Bachelor’s degree',
        'or equivalent qualification',
        'This should be an honours degree (Third or above), or equivalent'
      )
    end
  end

  context 'when course is not_required' do
    it 'renders correct message' do
      course = build(:course, degree_grade: :not_required)
      result = render_inline(described_class.new(course: course.decorate))

      expect(result.text).to include(
        'Bachelor’s degree',
        'or equivalent qualification'
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

    expect(page).to have_css('span', text: 'Non-UK citizens: check your qualifications')

    expect(page).to have_text('Some training providers need a certificate known as a statement of comparability that shows how your qualifications compare to UK ones.')
    expect(page).to have_text('There is a cost for the certificate and it takes 15 working days to arrive.')
    expect(page).to have_text('You can apply for a statement of comparability from UK ENIC (the UK European Network of Information Centres).')
    expect(page).to have_text('Learn more about how to check your qualifications meet the required standard.')

    expect(page).to have_link('apply for a statement of comparability from UK ENIC')
  end

  context 'when course is fee paying and can sponsor student visas' do
    let(:course) do
      build(
        :course,
        :fee_type_based,
        can_sponsor_student_visa: true,
        provider: build(:provider)
      )
    end

    it 'displays that student visas can be sponsored' do
      expect(result.text).to include('Student visas can be sponsored')
    end
  end

  context 'when course is salaried and can sponsor skilled worker visas' do
    let(:course) do
      build(
        :course,
        funding: 'salary',
        can_sponsor_skilled_worker_visa: true,
        provider: build(:provider)
      )
    end

    it 'displays that skilled worker visas can be sponsored' do
      expect(result.text).to include('Skilled Worker visas can be sponsored')
    end
  end

  context 'when course cannot sponsor visas' do
    let(:course) do
      build(
        :course,
        can_sponsor_student_visa: false,
        can_sponsor_skilled_worker_visa: false,
        provider: build(:provider)
      )
    end

    it 'displays that visas cannot be sponsored' do
      expect(result.text).to include('Visas cannot be sponsored')
    end
  end

  describe '#qualification_required' do
    let(:course) { build(:course) }

    it 'returns Degree' do
      component = described_class.new(course: course.decorate)
      render_inline(component)

      expect(component.qualification_required).to eq('Degree')
    end

    context 'when teacher_degree_apprenticeship' do
      let(:course) do
        build(
          :course,
          :with_teacher_degree_apprenticeship
        )
      end

      it 'returns A levels' do
        component = described_class.new(course: course.decorate)
        render_inline(component)

        expect(component.qualification_required).to eq('A levels')
      end
    end
  end
end

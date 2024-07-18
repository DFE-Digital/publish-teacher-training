# frozen_string_literal: true

require 'rails_helper'

module Find
  describe Results::SearchResultComponent, type: :component do
    context 'delegations' do
      subject { described_class.new(course: build(:course)) }

      it { is_expected.to delegate_method(:age_range_in_years_and_level).to(:course) }
    end

    context 'when the course specifies a required degree grade' do
      it 'renders correct message' do
        course = build(
          :course,
          degree_grade: :two_one
        )
        result = render_inline(described_class.new(course:))

        expect(result.text).to include(
          'An undergraduate degree at class 2:1 or above, or equivalent'
        )
      end
    end

    context 'when the provider specifies skilled worker visa sponsorship' do
      it 'renders correct message when only one kind of visa is sponsored' do
        course = build(
          :course,
          funding_type: 'salary',
          can_sponsor_student_visa: false,
          can_sponsor_skilled_worker_visa: true
        )
        result = render_inline(described_class.new(course:))

        expect(result.text).to include(
          'Skilled Worker visas can be sponsored'
        )
      end
    end

    context 'when the provider specifies skilled worker visa sponsorship for an unsalaried course' do
      it 'renders visas not sponsored message' do
        course = build(
          :course,
          funding_type: 'fee',
          can_sponsor_student_visa: false,
          can_sponsor_skilled_worker_visa: true
        )
        result = render_inline(described_class.new(course:))

        expect(result.text).to include(
          'Visas cannot be sponsored'
        )
      end
    end

    context 'when the provider specifies student visa sponsorship' do
      it 'renders correct message when only one kind of visa is sponsored' do
        course = build(:course, :can_sponsor_student_visa, :fee_type_based)
        result = render_inline(described_class.new(course:))

        expect(result.text).to include(
          'Student visas can be sponsored'
        )
      end

      it 'renders correct message when neither kind of visa is sponsored' do
        course = build(
          :course,
          can_sponsor_student_visa: false,
          can_sponsor_skilled_worker_visa: false
        )
        result = render_inline(described_class.new(course:))

        expect(result.text).to include(
          'Visas cannot be sponsored'
        )
      end
    end

    context 'when there is an accrediting provider' do
      it 'renders correct message' do
        course = build(
          :course,
          accrediting_provider: build(:provider, :accredited_provider, provider_name: 'ACME SCITT A1')
        )
        result = render_inline(described_class.new(course:))

        expect(result.text).to include('QTS ratified by ACME SCITT A1')
      end
    end

    context 'when there is no accrediting provider' do
      it 'renders correct message' do
        course = build(
          :course,
          accrediting_provider: nil
        )
        result = render_inline(described_class.new(course:))

        expect(result.text).not_to include('QTS ratified by')
      end
    end

    context 'when there are UK fees' do
      it 'renders the uk fees' do
        course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: 9250)]).decorate

        result = render_inline(described_class.new(course:))
        expect(result.text).to include('UK students: £9,250')
        expect(result.text).to include('Course fee')
      end
    end

    context 'when there are international fees' do
      it 'renders the international fees' do
        course = create(:course, enrichments: [create(:course_enrichment, fee_international: 14_000)]).decorate

        result = render_inline(described_class.new(course:))
        expect(result.text).to include('International students: £14,000')
      end
    end

    context 'when there are uk fees but no international fees' do
      it 'renders the uk fees and not the internation fee label' do
        course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: 9250, fee_international: nil)]).decorate

        result = render_inline(described_class.new(course:))

        expect(result.text).to include('UK students: £9,250')
        expect(result.text).not_to include('International students')
      end
    end

    context 'when there are international fees but no uk fees' do
      it 'renders the international fees but not the uk fee label' do
        course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: 14_000)]).decorate

        result = render_inline(described_class.new(course:))

        expect(result.text).not_to include('UK students')
        expect(result.text).to include('International students: £14,000')
      end
    end

    context 'when there are no fees' do
      it 'does not render the row' do
        course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: nil)]).decorate

        result = render_inline(described_class.new(course:))

        expect(result.text).not_to include('UK students')
        expect(result.text).not_to include('International students: £14,000')
        expect(result.text).not_to include('Course fee')
      end
    end

    context 'when there is an age_range_in_years_and_level' do
      it 'renders the age range and level' do
        course = build_stubbed(:course,
                               level: 'secondary',
                               age_range_in_years: '11_to_16')

        result = render_inline(described_class.new(course:))

        expect(result).to have_text('Age range 11 to 16 - secondary', normalize_ws: true)
      end
    end
  end
end

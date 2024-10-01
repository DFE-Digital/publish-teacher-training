# frozen_string_literal: true

require 'rails_helper'

module Find
  describe Results::SearchResultComponent, type: :component do
    let(:results_view) do
      ResultsView.new(query_parameters: { 'age_group' => 'primary',
                                          'applications_open' => 'true',
                                          'can_sponsor_visa' => 'false',
                                          'has_vacancies' => 'true',
                                          'l' => '2',
                                          'subjects' => ['00'],
                                          'visa_status' => 'false' })
    end

    context 'delegations' do
      subject { described_class.new(course: build(:course), results_view:) }

      it { is_expected.to delegate_method(:age_range_in_years_and_level).to(:course) }
      it { is_expected.to delegate_method(:course_length_with_study_mode).to(:course) }
    end

    context 'when the course specifies a required degree grade' do
      it 'renders correct message' do
        course = build(
          :course,
          degree_grade: :two_one
        )
        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).to include(
          '2:1 bachelor’s degree',
          'or above or equivalent qualification'
        )
      end
    end

    context 'when the provider specifies skilled worker visa sponsorship is active' do
      it 'renders correct message when only one kind of visa is sponsored' do
        course = build(
          :course,
          funding: 'salary',
          can_sponsor_student_visa: false,
          can_sponsor_skilled_worker_visa: true
        )
        result = render_inline(described_class.new(course:, results_view:))

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
        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).to include(
          'Visas cannot be sponsored'
        )
      end
    end

    context 'when the provider specifies student visa sponsorship' do
      it 'renders correct message when only one kind of visa is sponsored' do
        course = build(:course, :can_sponsor_student_visa, :fee_type_based)
        result = render_inline(described_class.new(course:, results_view:))

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
        result = render_inline(described_class.new(course:, results_view:))

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
        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).to include('QTS ratified by ACME SCITT A1')
      end
    end

    context 'when there is no accrediting provider' do
      it 'renders correct message' do
        course = build(
          :course,
          accrediting_provider: nil
        )
        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).not_to include('QTS ratified by')
      end
    end

    context 'when teacher degree apprenticeship course has incorrect fees' do
      it 'does not render fees' do
        course = create(:course, :apprenticeship, :published_teacher_degree_apprenticeship, enrichments: [create(:course_enrichment, fee_uk_eu: 9250)]).decorate

        result = render_inline(described_class.new(course:, results_view:))
        expect(result.text).not_to include('£9,250')
        expect(result.text).not_to include('Course fee')
      end
    end

    context 'when there are UK fees' do
      it 'renders the uk fees' do
        course = create(:course, :fee, enrichments: [create(:course_enrichment, fee_uk_eu: 9250)]).decorate

        result = render_inline(described_class.new(course:, results_view:))
        expect(result.text).to include('£9,250 for UK citizens')
        expect(result.text).to include('Course fee')
      end
    end

    context 'when there are international fees' do
      it 'renders the international fees' do
        course = create(:course, :fee, enrichments: [create(:course_enrichment, fee_international: 14_000)]).decorate

        result = render_inline(described_class.new(course:, results_view:))
        expect(result.text).to include('£14,000 for Non-UK citizens')
      end
    end

    context 'when there are uk fees but no international fees' do
      it 'renders the uk fees and not the internation fee label' do
        course = create(:course, :fee, enrichments: [create(:course_enrichment, fee_uk_eu: 9250, fee_international: nil)]).decorate

        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).to include('£9,250 for UK citizens')
        expect(result.text).not_to include('Non-UK citizens')
      end
    end

    context 'when there are international fees but no uk fees' do
      it 'renders the international fees but not the uk fee label' do
        course = create(:course, :fee, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: 14_000)]).decorate

        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).not_to include('for UK citizens')
        expect(result.text).to include('£14,000 for Non-UK citizens')
      end
    end

    context 'when there are no fees' do
      it 'does not render the row' do
        course = create(:course, :salary, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: nil)]).decorate

        result = render_inline(described_class.new(course:, results_view:))

        expect(result.text).not_to include('for UK citizens')
        expect(result.text).not_to include('£14,000 for Non-UK citizens')
        expect(result.text).not_to include('Course fee')
      end
    end

    context 'when there is an age_range_in_years_and_level' do
      it 'renders the age range and level' do
        course = build_stubbed(:course,
                               level: 'secondary',
                               age_range_in_years: '11_to_16')

        result = render_inline(described_class.new(course:, results_view:))

        expect(result).to have_text('Age range 11 to 16 - secondary', normalize_ws: true)
      end
    end

    context 'course length' do
      it 'renders the course length with study mode' do
        course = create(
          :course,
          enrichments: [build(:course_enrichment, :published, course_length: 'OneYear')],
          study_mode: 'full_time'
        )

        result = render_inline(described_class.new(course:, results_view:))

        expect(result).to have_text('Course length 1 year - full time', normalize_ws: true)
      end
    end

    context 'school placements (search by country or provider)' do
      context 'fee_based with 1 school' do
        it 'renders the school placement text' do
          course = create(
            :course,
            :with_full_time_sites
          )

          result = render_inline(described_class.new(course:, results_view:))

          expect(result).to have_text('Employing school')
          expect(result).to have_text('1 potential employing school')
        end
      end

      context 'fee_based with 2 schools' do
        it 'renders the school placement text' do
          course = create(
            :course,
            :with_2_full_time_sites
          )

          result = render_inline(described_class.new(course:, results_view:))

          expect(result).to have_text('Employing schools')
          expect(result).to have_text('2 potential employing schools')
        end
      end
    end
  end
end

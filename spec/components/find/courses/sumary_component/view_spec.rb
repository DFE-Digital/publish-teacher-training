# frozen_string_literal: true

require 'rails_helper'

module Find
  module Courses
    module SummaryComponent
      describe View do
        it 'renders sub sections' do
          provider = build(:provider).decorate
          course = create(:course, :draft_enrichment,
                          provider:).decorate

          result = render_inline(described_class.new(course))
          expect(result.text).to include(
            'Fee or salary',
            'Qualification',
            'Course length',
            'Qualification',
            'Date you can apply from',
            'Date course starts',
            'Website'
          )
        end

        context 'a course has an accrediting provider that is not the provider' do
          it 'renders the accredited provider' do
            course = build(
              :course,
              provider: build(:provider),
              accrediting_provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include(
              'Accredited provider'
            )
          end
        end

        context 'the course provider and accrediting provider are the same' do
          it 'does not render the accredited provider' do
            provider = build(:provider)

            course = build(
              :course,
              provider:,
              accrediting_provider: provider
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).not_to include(
              'Accredited provider'
            )
          end
        end

        context 'secondary course' do
          it 'renders the age range and level' do
            course = build(
              :course,
              :secondary,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.css('[data-qa="course__age_range"]').text).to have_text('11 to 18 - secondary')
          end
        end

        context 'non-secondary course' do
          it 'render the age range only' do
            course = build(
              :course,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.css('[data-qa="course__age_range"]').text).to eq('3 to 7')
          end
        end

        context 'when course is fee paying and can sponsor student visas' do
          it 'displays that student visas can be sponsored' do
            course = build(
              :course,
              :fee_type_based,
              can_sponsor_student_visa: true,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('Student visas can be sponsored')
          end
        end

        context 'when course is salaried and can sponsor skilled worker visas' do
          it 'displays that skilled worker visas can be sponsored' do
            course = build(
              :course,
              :with_salary,
              can_sponsor_skilled_worker_visa: true,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('Skilled Worker visas can be sponsored')
          end
        end

        context 'when course cannot sponsor visas' do
          it 'displays that visas cannot be sponsored' do
            course = build(
              :course,
              can_sponsor_student_visa: false,
              can_sponsor_skilled_worker_visa: false,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('Visas cannot be sponsored')
          end
        end

        context 'when there are UK fees' do
          it 'renders the uk fees' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: 9250)]).decorate

            result = render_inline(described_class.new(course))
            expect(result.text).to include('UK students: £9,250')
          end
        end

        context 'when there are international fees' do
          it 'renders the international fees' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_international: 14_000)]).decorate

            result = render_inline(described_class.new(course))
            expect(result.text).to include('International students: £14,000')
          end
        end

        context 'when there are uk fees but no international fees' do
          it 'renders the uk fees and not the internation fee label' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: 9250, fee_international: nil)]).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('UK students: £9,250')
            expect(result.text).not_to include('International students')
          end
        end

        context 'when there are international fees but no uk fees' do
          it 'renders the international fees but not the uk fee label' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: 14_000)]).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).not_to include('UK students')
            expect(result.text).to include('International students: £14,000')
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

module Find
  module Courses
    module SummaryComponent
      describe View do
        it 'renders sub sections' do
          provider = build(:provider).decorate
          course = create(:course, :draft_enrichment, applications_open_from: Time.zone.tomorrow, provider:).decorate

          result = render_inline(described_class.new(course))
          expect(result.text).to include(
            'Fee or salary',
            'Course fee',
            'Course length',
            'Age range',
            'Qualification',
            'Provider',
            'Date you can apply from',
            'Start date'
          )
        end

        context 'applications open date has not passed' do
          it "renders the 'Date you can apply from'" do
            course = build(
              :course,
              applications_open_from: Time.zone.tomorrow,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('Date you can apply from')
          end
        end

        context 'applications open date has passed' do
          it "does not render the 'Date you can apply from'" do
            course = build(
              :course,
              applications_open_from: Time.zone.yesterday,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).not_to include('Date you can apply from')
          end
        end

        context 'applications open date is today' do
          it "does not render the 'Date you can apply from'" do
            course = build(
              :course,
              applications_open_from: Time.zone.today,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).not_to include('Date you can apply from')
          end
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
              'Accredited by'
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

            expect(result.text).to include('11 to 18 - secondary')
          end
        end

        context 'non-secondary course' do
          it 'render the age range only' do
            course = build(
              :course,
              provider: build(:provider)
            ).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('3 to 7')
          end
        end

        context 'when there are UK fees' do
          it 'renders the uk fees' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: 9250)]).decorate

            result = render_inline(described_class.new(course))
            expect(result.text).to include('£9,250 for UK citizens')
            expect(result.text).to include('Course fee')
          end
        end

        context 'when there are international fees' do
          it 'renders the international fees' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_international: 14_000)]).decorate

            result = render_inline(described_class.new(course))
            expect(result.text).to include('£14,000 for non-UK citizens')
          end
        end

        context 'when there are uk fees but no international fees' do
          it 'renders the uk fees and not the internation fee label' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: 9250, fee_international: nil)]).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).to include('£9,250 for UK citizens')
            expect(result.text).not_to include('for non-UK citizens')
          end
        end

        context 'when there are international fees but no uk fees' do
          it 'renders the international fees but not the uk fee label' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: 14_000)]).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).not_to include('for UK citizens')
            expect(result.text).to include('£14,000 for non-UK citizens')
          end
        end

        context 'when there are no fees' do
          it 'does not render the row' do
            course = create(:course, enrichments: [create(:course_enrichment, fee_uk_eu: nil, fee_international: nil)]).decorate

            result = render_inline(described_class.new(course))

            expect(result.text).not_to include('for UK citizens')
            expect(result.text).not_to include('£14,000 for non-UK citizens')
            expect(result.text).not_to include('Course fee')
          end
        end
      end
    end
  end
end

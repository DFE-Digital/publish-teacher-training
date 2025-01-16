# frozen_string_literal: true

require 'rails_helper'

describe Shared::Courses::FinancialSupport::FeesAndFinancialSupportComponent::View, type: :component do
  context 'Salaried courses' do
    it 'renders salaried course section if the course has a salary' do
      course = build(:course, funding: 'salary').decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('How salaried courses work')
    end

    it 'does not render salaried course section if the course does not have a salary' do
      course = build(:course, funding: 'fee', subjects: [build(:secondary_subject, bursary_amount: '3000')]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include('How salaried courses work')
    end
  end

  context 'Courses excluded from bursary' do
    it 'renders the student loans section if the course is excluded from bursary' do
      course = build(:course, funding: 'fee', name: 'Drama', subjects: [build(:secondary_subject), build(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('You may be eligible for student loans to cover the cost of your tuition fee or to help with living costs.')
    end
  end

  context 'Courses with bursary' do
    it 'renders the bursary section if the course has a bursary' do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)

      course = build(:course, funding: 'fee', name: 'History', subjects: [build(:secondary_subject, bursary_amount: '2000'), build(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('Bursaries')
      expect(result.text).to include('This course has a bursary of £2,000 available to eligible trainees.')
    end
  end

  context 'Courses with scholarship and bursary' do
    it 'renders the scholarships and bursary section' do
      FeatureFlag.activate(:bursaries_and_scholarships_announced)

      course = build(:course, funding: 'fee', name: 'History', subjects: [build(:secondary_subject, bursary_amount: '2000', scholarship: '1000'), build(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('Bursaries and scholarships')
      expect(result.text).to include('Bursaries of £2,000 and scholarships of £1,000 are available to eligible trainees.')
    end
  end

  context 'Courses with student loans' do
    it 'renders the student loans section if the course is not salaried, does not have a bursary or scholarship and does not meet bursary exclusion criteria' do
      course = create(:course, funding: 'fee', name: 'Drama', subjects: [create(:primary_subject), create(:secondary_subject)]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('You may be eligible for student loans to cover the cost of your tuition fee or to help with living costs.')
    end
  end

  context 'Fee paying courses' do
    it 'renders the fees section' do
      course = create(:course, name: 'Music', enrichments: [create(:course_enrichment, fee_uk_eu: '5000', fee_details: 'Some fee details')], funding: 'fee').decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include('Some fee details')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesQuery do
  describe '.call' do
    subject(:results) { described_class.call(query) }

    context 'when no filters or sorting are applied' do
      let!(:findable_course) { create(:course, :with_full_time_sites) }
      let!(:another_course) { create(:course, :with_full_time_sites) }
      let!(:non_findable_course) { create(:course) }

      let(:query) { {} }

      it 'returns all findable courses' do
        expect(results).to contain_exactly(findable_course, another_course)
      end
    end

    context 'when filter for visa sponsorship' do
      let!(:course_that_sponsor_visa) do
        create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa)
      end
      let!(:another_course_that_sponsor_visa) do
        create(:course, :with_full_time_sites, :can_sponsor_student_visa)
      end
      let!(:another_course_that_sponsor_all_visas) do
        create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa)
      end
      let!(:course_that_does_not_sponsor_visa) do
        create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false)
      end

      let(:query) { { can_sponsor_visa: true } }

      it 'returns courses that sponsor visa' do
        expect(results).to match_collection(
          [course_that_sponsor_visa, another_course_that_sponsor_visa, another_course_that_sponsor_all_visas],
          attribute_names: %w[can_sponsor_skilled_worker_visa can_sponsor_student_visa]
        )
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesQuery do
  describe '.call' do
    subject(:results) { described_class.call(params:) }

    context 'when no filters or sorting are applied' do
      let!(:findable_course) { create(:course, :with_full_time_sites) }
      let!(:another_course) { create(:course, :with_full_time_sites) }
      let!(:non_findable_course) { create(:course) }

      let(:params) { {} }

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

      let(:params) { { can_sponsor_visa: 'true' } }

      it 'returns courses that sponsor visa' do
        expect(results).to match_collection(
          [course_that_sponsor_visa, another_course_that_sponsor_visa, another_course_that_sponsor_all_visas],
          attribute_names: %w[can_sponsor_skilled_worker_visa can_sponsor_student_visa]
        )
      end
    end

    context 'when filter by study mode' do
      let!(:full_time_course) do
        create(:course, :with_full_time_sites, study_mode: 'full_time', name: 'Biology', course_code: 'S872')
      end
      let!(:part_time_course) do
        create(:course, :with_part_time_sites, study_mode: 'part_time', name: 'Chemistry', course_code: 'K592')
      end
      let!(:full_time_or_part_time_course) do
        create(:course, :with_full_time_or_part_time_sites, study_mode: 'full_time_or_part_time', name: 'Computing', course_code: 'L364')
      end

      context 'when filter by full time only' do
        let(:params) { { study_types: ['', 'full_time'] } }

        it 'returns full time courses only' do
          expect(results).to match_collection(
            [full_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end

      context 'when filter by part time only' do
        let(:params) { { study_types: ['', 'part_time'] } }

        it 'returns part time courses only' do
          expect(results).to match_collection(
            [part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end

      context 'when filter by full time and part time' do
        let(:params) { { study_types: ['', 'full_time', 'part_time'] } }

        it 'returns full time and part time courses' do
          expect(results).to match_collection(
            [full_time_course, part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end
    end

    context 'when filter for applications open' do
      let!(:course_opened) do
        create(:course, :with_full_time_sites, :open)
      end
      let!(:course_closed) do
        create(:course, :with_full_time_sites, :closed)
      end
      let(:params) { { applications_open: 'true' } }

      it 'returns courses that sponsor visa' do
        expect(results).to match_collection(
          [course_opened],
          attribute_names: %w[application_status]
        )
      end
    end

    context 'when filter for special education needs' do
      let!(:course_with_special_education_needs) do
        create(:course, :with_full_time_sites, :with_special_education_needs)
      end
      let!(:course_with_no_special_education_needs) do
        create(:course, :with_full_time_sites, is_send: false)
      end
      let(:params) { { send_courses: 'true' } }

      it 'returns courses that sponsor visa' do
        expect(results).to match_collection(
          [course_with_special_education_needs],
          attribute_names: %w[is_send]
        )
      end
    end
  end
end

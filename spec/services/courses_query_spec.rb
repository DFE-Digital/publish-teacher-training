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

    context 'when filter by secondary subjects' do
      let!(:biology) do
        create(:course, :with_full_time_sites, :secondary, name: 'Biology', subjects: [find_or_create(:secondary_subject, :biology)])
      end
      let!(:chemistry) do
        create(:course, :with_full_time_sites, :secondary, name: 'Chemistry', subjects: [find_or_create(:secondary_subject, :chemistry)])
      end
      let!(:mathematics) do
        create(:course, :with_full_time_sites, :secondary, name: 'Mathematics', subjects: [find_or_create(:secondary_subject, :mathematics)])
      end

      let(:params) { { subjects: %w[C1 F1] } }

      it 'returns specific secondary courses' do
        expect(results).to match_collection(
          [biology, chemistry],
          attribute_names: %w[name]
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
        let(:params) { { study_types: ['full_time'] } }

        it 'returns full time courses only' do
          expect(results).to match_collection(
            [full_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end

      context 'when filter by part time only' do
        let(:params) { { study_types: ['part_time'] } }

        it 'returns part time courses only' do
          expect(results).to match_collection(
            [part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end

      context 'when filter by full time and part time' do
        let(:params) { { study_types: %w[full_time part_time] } }

        it 'returns full time and part time courses' do
          expect(results).to match_collection(
            [full_time_course, part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end

      context 'when pass invalid parameter' do
        let(:params) { { study_types: 'something' } }

        it 'returns full time and part time courses' do
          expect(results).to match_collection(
            [full_time_course, part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode]
          )
        end
      end
    end

    context 'when filter by qualifications' do
      let!(:qts_course) do
        create(:course, :with_full_time_sites, qualification: 'qts')
      end
      let!(:pgce_with_qts_course) do
        create(:course, :with_full_time_sites, qualification: 'pgce_with_qts')
      end
      let!(:pgde_with_qts_course) do
        create(:course, :with_full_time_sites, qualification: 'pgde_with_qts')
      end
      let!(:course_without_qts) do
        create(:course, :with_full_time_sites, qualification: 'undergraduate_degree_with_qts')
      end

      context 'when filter by qts' do
        let(:params) { { qualifications: ['qts'] } }

        it 'returns courses with qts qualification only' do
          expect(results).to match_collection(
            [qts_course],
            attribute_names: %w[qualification]
          )
        end
      end

      context 'when filter by qts with pgce or pgde' do
        let(:params) { { qualifications: ['qts_with_pgce_or_pgde'] } }

        it 'returns courses with qts and pgce/pgde qualifications' do
          expect(results).to match_collection(
            [pgce_with_qts_course, pgde_with_qts_course],
            attribute_names: %w[qualification]
          )
        end
      end

      context 'when filter by qts with pgce (for backwards compatibility)' do
        let(:params) { { qualifications: ['qts_with_pgce'] } }

        it 'returns courses with qts and pgce/pgde qualifications' do
          expect(results).to match_collection(
            [pgce_with_qts_course, pgde_with_qts_course],
            attribute_names: %w[qualification]
          )
        end
      end
    end

    context 'when filter for further education' do
      let!(:further_education_course) do
        create(:course, :with_full_time_sites, level: 'further_education')
      end
      let!(:regular_course) do
        create(:course, :with_full_time_sites, level: 'secondary')
      end
      let(:params) { { further_education: 'true' } }

      it 'returns courses for further education only' do
        expect(results).to match_collection(
          [further_education_course],
          attribute_names: %w[level]
        )
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

    context 'when filter by funding' do
      let!(:fee_course) do
        create(:course, :with_full_time_sites, funding: 'fee')
      end
      let!(:salaried_course) do
        create(:course, :with_full_time_sites, funding: 'salary')
      end
      let!(:apprenticeship_course) do
        create(:course, :with_full_time_sites, funding: 'apprenticeship')
      end

      context 'when filter by fee' do
        let(:params) { { funding: ['fee'] } }

        it 'returns courses with fees only' do
          expect(results).to match_collection(
            [fee_course],
            attribute_names: %w[funding]
          )
        end
      end

      context 'when filter by salary' do
        let(:params) { { funding: ['salary'] } }

        it 'returns courses with salary' do
          expect(results).to match_collection(
            [salaried_course],
            attribute_names: %w[funding]
          )
        end
      end

      context 'when filter by apprenticeship' do
        let(:params) { { funding: ['apprenticeship'] } }

        it 'returns courses with apprenticeship' do
          expect(results).to match_collection(
            [apprenticeship_course],
            attribute_names: %w[funding]
          )
        end
      end

      context 'when filter by salary in the old search parameter' do
        let(:params) { { funding: 'salary' } }

        it 'returns courses with salary' do
          expect(results).to match_collection(
            [salaried_course],
            attribute_names: %w[funding]
          )
        end
      end

      context 'when filter by two funding types' do
        let(:params) { { funding: %w[fee salary] } }

        it 'returns courses with the expected funding types' do
          expect(results).to match_collection(
            [fee_course, salaried_course],
            attribute_names: %w[funding]
          )
        end
      end

      context 'when filter by all funding types' do
        let(:params) { { funding: %w[fee salary apprenticeship] } }

        it 'returns all courses' do
          expect(results).to match_collection(
            [fee_course, salaried_course, apprenticeship_course],
            attribute_names: %w[funding]
          )
        end
      end
    end
  end
end

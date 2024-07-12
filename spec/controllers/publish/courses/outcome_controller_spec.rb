# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::Courses::OutcomeController do
  let(:recruitment_cycle) { create(:recruitment_cycle, year: 2025) }
  let(:user) { create(:user, providers: [build(:provider, recruitment_cycle:)]) }
  let(:provider) { user.providers.first }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    controller.instance_variable_set(:@current_user, user)
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  describe '#edit' do
    context 'when teacher degree apprenticeship published course' do
      it 'redirects to the course page' do
        course = create(
          :course,
          :resulting_in_undergraduate_degree_with_qts,
          :with_teacher_degree_apprenticeship,
          :published,
          provider:,
          study_mode: :part_time,
          site_statuses: [build(:site_status, :part_time_vacancies, :findable)]
        )

        get :edit, params: {
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          code: course.course_code
        }

        expect(response).to redirect_to(
          publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            course.course_code
          )
        )
      end
    end

    context 'when teacher degree apprenticeship draft course' do
      it 'renders the edit outcome' do
        course = create(
          :course,
          :resulting_in_undergraduate_degree_with_qts,
          :with_teacher_degree_apprenticeship,
          :draft_enrichment,
          provider:,
          study_mode: :part_time,
          site_statuses: [build(:site_status, :part_time_vacancies, :findable)]
        )

        get :edit, params: {
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          code: course.course_code
        }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#update' do
    context 'when changing from a QTS to teacher degree apprenticeship course' do
      it 'assigns teacher degree apprenticeship course defaults' do
        course = create(
          :course,
          :resulting_in_qts,
          provider:,
          study_mode: :part_time,
          site_statuses: [build(:site_status, :part_time_vacancies, :findable)]
        )
        create(:course_enrichment, :initial_draft, course_length: :TwoYears, course:)

        put :update, params: {
          course: { qualification: 'undergraduate_degree_with_qts' },
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          code: course.course_code
        }

        course.reload

        expect(course.funding_type).to eq('apprenticeship')
        expect(course.can_sponsor_skilled_worker_visa).to be(false)
        expect(course.can_sponsor_student_visa).to be(false)
        expect(course.additional_degree_subject_requirements).to be(false)
        expect(course.degree_subject_requirements).to be_nil
        expect(course.degree_grade).to eq('not_required')
        expect(course.study_mode).to eq('full_time')
        expect(course.site_statuses.map(&:vac_status).uniq.first).to eq('full_time_vacancies')
        expect(course.enrichments.max_by(&:created_at).course_length).to eq('4 years')
      end
    end

    context 'when changing from teacher degree apprenticeship to a QTS course' do
      it 'clear teacher degree specific defaults' do
        course = create(
          :course,
          :with_teacher_degree_apprenticeship,
          :resulting_in_undergraduate_degree_with_qts,
          :with_a_level_requirements,
          provider:
        )

        put :update, params: {
          course: { qualification: 'qts' },
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          code: course.course_code
        }

        course.reload

        expect(course.a_level_subject_requirements).to eq([])
        expect(course.accept_a_level_equivalency).to be_nil
        expect(course.accept_pending_a_level).to be_nil
        expect(course.additional_a_level_equivalencies).to be_nil
      end
    end
  end
end

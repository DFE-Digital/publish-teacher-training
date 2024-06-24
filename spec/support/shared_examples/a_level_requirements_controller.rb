# frozen_string_literal: true

shared_examples 'an A level requirements controller' do
  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    controller.instance_variable_set(:@current_user, user)
  end

  context 'when teacher degree apprenticeship' do
    let(:course) do
      create(
        :course,
        :with_teacher_degree_apprenticeship,
        :with_gcse_equivalency,
        :with_accrediting_provider,
        enrichments: [build(:course_enrichment, :initial_draft)],
        sites: [create(:site, location_name: 'location 1')],
        study_sites: [create(:site, :study_site)],
        provider:
      )
    end

    it 'returns successful response' do
      get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when not teacher degree apprenticeship' do
    let(:course) do
      create(
        :course,
        :with_gcse_equivalency,
        :with_accrediting_provider,
        enrichments: [build(:course_enrichment, :initial_draft)],
        sites: [create(:site, location_name: 'location 1')],
        study_sites: [create(:site, :study_site)],
        provider:
      )
    end

    it 'redirects to courses page' do
      get :new, params: { provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code }
      expect(response).to redirect_to(publish_provider_recruitment_cycle_courses_path(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year))
    end
  end
end

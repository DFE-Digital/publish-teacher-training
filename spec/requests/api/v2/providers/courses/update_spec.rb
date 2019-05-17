require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  def perform_request(attributes)
    patch "/api/v2/providers/#{provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            course: attributes
          }
  end

  let(:organisation) { create :organisation }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:course)       { create :course, provider: provider }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:update_attributes) do
    {
      about_course: 'new about course',
      course_length: 'new course length',
      fee_details: 'new fee details',
      fee_international: 'new fee international',
      fee_uk_eu: 'new fee uk eu',
      financial_support: 'new financial support',
      how_school_placements_work: 'new how school placements work',
      interview_process: 'new interview process',
      other_requirements: 'new other requirements',
      personal_qualities: 'new personal qualities',
      qualifications: 'new qualifications',
      salary_details: 'new salary details'
    }.stringify_keys
  end

  describe 'with unpermitted attributes on course object' do
    shared_examples 'does not allow assigning course attribute' do |attribute|
      it "doesn't permit #{attribute}" do
        expect {
          perform_request(attribute => "a new #{attribute}")
        }.to raise_error(ActionController::UnpermittedParameters)
      end
    end

    include_examples 'does not allow assigning course attribute', :age_range
    include_examples 'does not allow assigning course attribute', :course_code
    include_examples 'does not allow assigning course attribute', :name
    include_examples 'does not allow assigning course attribute', :profpost_flag
    include_examples 'does not allow assigning course attribute', :program_type
    include_examples 'does not allow assigning course attribute', :qualification
    include_examples 'does not allow assigning course attribute', :start_date
    include_examples 'does not allow assigning course attribute', :study_mode
    include_examples 'does not allow assigning course attribute', :accrediting_provider_id
    include_examples 'does not allow assigning course attribute', :provider_id
    include_examples 'does not allow assigning course attribute', :modular
    include_examples 'does not allow assigning course attribute', :english
    include_examples 'does not allow assigning course attribute', :maths
    include_examples 'does not allow assigning course attribute', :science
    include_examples 'does not allow assigning course attribute', :created_at
    include_examples 'does not allow assigning course attribute', :updated_at
    include_examples 'does not allow assigning course attribute', :changed_at
  end

  context 'course has no enrichments' do
    it "creates a draft enrichment for the course" do
      expect {
        perform_request update_attributes
      }.to(change {
             course.enrichments.reload.count
           }.from(0).to(1))

      draft_enrichment = course.enrichments.reload.draft.first
      expect(draft_enrichment.attributes.slice(*update_attributes.keys))
        .to include(update_attributes)
    end
  end

  context 'course has a draft enrichment' do
    let(:enrichment) { build :course_enrichment }
    let(:course) do
      create :course, provider: provider, enrichments: [enrichment]
    end

    it "updates the course's draft enrichment" do
      expect {
        perform_request update_attributes
      }.not_to(
        change { course.enrichments.reload.count }
      )

      draft_enrichment = course.enrichments.reload.draft.first
      expect(draft_enrichment.attributes.slice(*update_attributes.keys))
        .to include(update_attributes)
    end
  end

  context 'course has only a published enrichment' do
    let(:enrichment) { build :course_enrichment, :published }
    let(:course) do
      create :course, provider: provider, enrichments: [enrichment]
    end

    it "creates a draft enrichment for the course" do
      expect { perform_request update_attributes }
        .to(change { course.enrichments.reload.count }
              .from(1).to(2))

      draft_enrichment = course.enrichments.reload.draft.first
      expect(draft_enrichment.attributes.slice(*update_attributes.keys))
        .to include(update_attributes)
    end
  end
end

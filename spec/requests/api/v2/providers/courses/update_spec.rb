require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(course)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data.dig(:data, :attributes).slice!(*permitted_params)

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end

  let(:organisation) { create :organisation }
  let(:provider)     { create :provider, organisations: [organisation] }
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:course)       { create :course, provider: provider }
  let(:update_enrichment) { build :course_enrichment, **update_attributes }
  # we need an unsaved course to add the enrichment to (so that it isn't
  # persisted)
  let(:update_course) { course.dup.tap { |c| c.enrichments << update_enrichment } }

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
      qualifications: 'new required qualifications',
      salary_details: 'new salary details'
    }
  end
  let(:permitted_params) do
    %i[
      about_course
      course_length
      fee_details
      fee_international
      fee_uk_eu
      financial_support
      how_school_placements_work
      interview_process
      other_requirements
      personal_qualities
      required_qualifications
      salary_details
    ]
  end

  describe 'with unpermitted attributes on course object' do
    shared_examples 'does not allow assignment' do |attribute, value|
      it "doesn't permit #{attribute}" do
        update_course = build(:course, attribute => value, provider: provider)
        update_course.id = course.id
        perform_request(course)
        expect(course.reload.send(attribute)).not_to eq(value)
      end
    end

    include_examples 'does not allow assignment', :age_range, 'primary'
    include_examples 'does not allow assignment', :course_code, 'CZ'
    include_examples 'does not allow assignment', :name, 'Name'
    include_examples 'does not allow assignment', :profpost_flag, 'BO'
    include_examples 'does not allow assignment', :program_type, 'SC'
    include_examples 'does not allow assignment', :qualification, 2
    include_examples 'does not allow assignment', :start_date, Date.yesterday
    include_examples 'does not allow assignment', :study_mode, 'P'
    include_examples 'does not allow assignment', :modular, 'Modular'
    include_examples 'does not allow assignment', :english, 2
    include_examples 'does not allow assignment', :maths, 2
    include_examples 'does not allow assignment', :science, 2
    include_examples 'does not allow assignment', :created_at, Date.yesterday
    include_examples 'does not allow assignment', :updated_at, Date.yesterday
    include_examples 'does not allow assignment', :changed_at, Date.yesterday

    it "doesn't allow updating of provider" do
      another_provider = create(:provider)
      update_course    = build(
        :course,
        provider_id: another_provider.id,
        provider:    provider
      )
      update_course.id = course.id

      perform_request(course)

      expect(course.reload.provider_id).not_to eq(another_provider.id)
    end

    it "doesn't allow updating of accrediting provider" do
      another_provider = create(:provider)
      update_course    = build(
        :course,
        accrediting_provider_id: another_provider.id,
        provider:                provider
      )
      update_course.id = course.id

      perform_request(course)

      expect(course.reload.accrediting_provider_id).not_to eq(another_provider.id)
    end
  end

  context 'course has no enrichments' do
    it "creates a draft enrichment for the course" do
      expect {
        perform_request update_course
      }.to(change {
             course.reload.enrichments.count
           }.from(0).to(1))

      draft_enrichment = course.enrichments.draft.first
      expect(draft_enrichment.attributes.slice(*update_attributes.keys.map(&:to_s)))
        .to include(update_attributes.stringify_keys)
    end

    context "with no attributes to update" do
      let(:update_attributes) do
        {
          about_course: nil,
          course_length: nil,
          fee_details: nil,
          fee_international: nil,
          fee_uk_eu: nil,
          financial_support: nil,
          how_school_placements_work: nil,
          interview_process: nil,
          other_requirements: nil,
          personal_qualities: nil,
          qualifications: nil,
          salary_details: nil
        }
      end

      it "doesn't create a draft enrichment" do
        expect {
          perform_request update_course
        }.to_not(change { course.reload.enrichments.count })
      end
    end

    context "with empty attributes" do
      let(:permitted_params) { [] }

      it "doesn't create a draft enrichment" do
        expect {
          perform_request update_course
        }.to_not(change { course.reload.enrichments.count })
      end
    end

    it 'returns ok' do
      perform_request update_course

      expect(response).to be_ok
    end

    it 'returns the updated course' do
      perform_request update_course
      json_response = JSON.parse(response.body)['data']

      expect(json_response).to have_id(course.id.to_s)
      expect(json_response).to have_type('courses')
      expect(json_response).to have_attribute(:about_course)
        .with_value('new about course')
      expect(json_response).to have_attribute(:course_length)
        .with_value('new course length')
      expect(json_response).to have_attribute(:fee_details)
        .with_value('new fee details')
      expect(json_response).to have_attribute(:fee_international)
        .with_value('new fee international')
      expect(json_response).to have_attribute(:fee_uk_eu)
        .with_value('new fee uk eu')
      expect(json_response).to have_attribute(:financial_support)
        .with_value('new financial support')
      expect(json_response).to have_attribute(:how_school_placements_work)
        .with_value('new how school placements work')
      expect(json_response).to have_attribute(:interview_process)
        .with_value('new interview process')
      expect(json_response).to have_attribute(:other_requirements)
        .with_value('new other requirements')
      expect(json_response).to have_attribute(:personal_qualities)
        .with_value('new personal qualities')
      expect(json_response).to have_attribute(:required_qualifications)
        .with_value('new required qualifications')
      expect(json_response).to have_attribute(:salary_details)
        .with_value('new salary details')
    end
  end

  context 'course has a draft enrichment' do
    let(:enrichment) { build :course_enrichment }
    let(:course) do
      create :course, provider: provider, enrichments: [enrichment]
    end

    it "updates the course's draft enrichment" do
      expect {
        perform_request update_course
      }.not_to(
        change { course.enrichments.reload.count }
      )

      draft_enrichment = course.enrichments.draft.first
      expect(draft_enrichment.attributes.slice(*update_attributes.keys.map(&:to_s)))
        .to include(update_attributes.stringify_keys)
    end

    context "with invalid data" do
      let(:update_attributes) do
        {
          about_course: Faker::Lorem.sentence(1000),
          fee_details: Faker::Lorem.sentence(1000),
          fee_international: 200_000,
          fee_uk_eu: 200_000,
          financial_support: Faker::Lorem.sentence(1000),
          how_school_placements_work: Faker::Lorem.sentence(1000),
          interview_process: Faker::Lorem.sentence(1000),
          other_requirements: Faker::Lorem.sentence(1000),
          personal_qualities: Faker::Lorem.sentence(1000),
          qualifications: Faker::Lorem.sentence(1000),
          salary_details: Faker::Lorem.sentence(1000)
        }
      end

      subject { JSON.parse(response.body)["errors"].map { |e| e["title"] } }

      it "returns validation errors" do
        perform_request update_course

        prefix = "Invalid latest_enrichment__"
        expect("#{prefix}about_course".in?(subject)).to eq(true)
        expect("#{prefix}interview_process".in?(subject)).to eq(true)
        expect("#{prefix}how_school_placements_work".in?(subject)).to eq(true)
        expect("#{prefix}qualifications".in?(subject)).to eq(true)
        expect("#{prefix}fee_details".in?(subject)).to eq(true)
        expect("#{prefix}financial_support".in?(subject)).to eq(true)
      end
    end

    context "with nil data" do
      let(:update_attributes) do
        {
          about_course: "",
          fee_details: "",
          fee_international: "",
          fee_uk_eu: "",
          financial_support: "",
          how_school_placements_work: "",
          interview_process: "",
          other_requirements: "",
          personal_qualities: "",
          qualifications: "",
          salary_details: ""
        }
      end

      it "returns ok" do
        perform_request update_course

        expect(response).to be_ok
      end
    end
  end

  context 'course has only a published enrichment' do
    let(:enrichment) { build :course_enrichment, :published }
    let(:course) do
      create :course, provider: provider, enrichments: [enrichment]
    end

    it "creates a draft enrichment for the course" do
      expect { perform_request update_course }
        .to(
          change { course.enrichments.reload.draft.count }
            .from(0).to(1)
        )

      draft_enrichment = course.enrichments.draft.first
      expect(draft_enrichment.attributes.slice(*update_attributes.keys.map(&:to_s)))
        .to include(update_attributes.stringify_keys)
    end
  end
end

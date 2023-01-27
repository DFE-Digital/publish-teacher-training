# frozen_string_literal: true

require 'rails_helper'

describe 'GET v3/recruitment_cycle/:recruitment_cycle_year/providers/:provider_code/courses/:course_code', :with_publish_constraint do
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_year)  { current_cycle.year.to_i }
  let(:previous_year) { current_year - 1 }
  let(:next_year)     { current_year + 1 }
  let(:provider) { create(:provider, recruitment_cycle: current_cycle) }
  let(:courses_site_status) do
    build(:site_status,
      :findable,
      :full_time_vacancies,
      site: create(:site, provider:))
  end

  let(:jsonapi_course) do
    JSON.parse(
      JSONAPI::Serializable::Renderer.new.render(
        course,
        class: {
          Course: API::V3::SerializableCourse
        }
      ).to_json
    )
  end
  let(:jsonapi_response) { JSON.parse(response.body) }
  let(:route) do
    "/api/v3/recruitment_cycles/#{current_year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}"
  end
  let(:course) do
    create(:course,
      :with_gcse_equivalency,
      provider:,
      enrichments:,
      site_statuses: [courses_site_status],
      applications_open_from: Time.now.utc)
  end

  context 'with a published course' do
    let(:enrichments) { [build(:course_enrichment, :published)] }

    it 'returns full course information' do
      get route

      expect(jsonapi_response['data']).to eq jsonapi_course['data']
    end

    it 'returns sparse course information' do
      requested_fields = %w[course_code name provider_code].sort
      get route + "?fields[courses]=#{requested_fields.join(',')}"

      expect(jsonapi_response['data']['attributes'].keys).to eq requested_fields
    end
  end

  context 'with a course with no enrichments' do
    let(:enrichments) { [] }

    it 'returns nil course information' do
      get route

      expect(jsonapi_response['data']).to be_nil
    end
  end

  context 'with a course with a draft enrichment' do
    let(:enrichments) { [build(:course_enrichment, :initial_draft)] }

    it 'returns nil course information' do
      get route

      expect(jsonapi_response['data']).to be_nil
    end
  end

  context 'with sites included' do
    let(:enrichments) do
      [
        build(:course_enrichment, :published, fee_details: 'Some details about the fees'),
        build(:course_enrichment, :published, fee_details: 'Some new details about the fees'),
        build(:course_enrichment, :subsequent_draft)
      ]
    end
    let(:enrichment) { course.enrichments.second }

    before do
      get "/api/v3/recruitment_cycles/#{current_year}" \
          "/providers/#{provider.provider_code.downcase}" \
          "/courses/#{course.course_code.downcase}",
        params: { include: 'sites' }
    end

    it 'has a data section with the correct attributes' do
      json_response = JSON.parse response.body

      changed_at = json_response['data']['attributes'].delete('changed_at')
      expect(Time.zone.parse(changed_at)).to be_within(10).of(Time.zone.now)

      last_published_at = json_response['data']['attributes'].delete('last_published_at')
      expect(Time.zone.parse(last_published_at)).to be_within(10).of(enrichment.last_published_timestamp_utc)

      expect(json_response).to eq(
        'data' => {
          'id' => course.id.to_s,
          'type' => 'courses',
          'attributes' => {
            'findable?' => true,
            'open_for_applications?' => true,
            'has_vacancies?' => true,
            'name' => course.name,
            'course_code' => course.course_code,
            'start_date' => course.start_date.strftime('%B %Y'),
            'study_mode' => 'full_time',
            'qualification' => 'pgce_with_qts',
            'description' => 'PGCE with QTS full time teaching apprenticeship',
            'content_status' => 'published_with_unpublished_changes',
            'ucas_status' => 'running',
            'funding_type' => 'apprenticeship',
            'is_send?' => false,
            'level' => 'primary',
            'applications_open_from' => course.applications_open_from.to_s,
            'provider_type' => provider.provider_type,
            'about_course' => enrichment.about_course,
            'course_length' => enrichment.course_length,
            'fee_details' => 'Some new details about the fees',
            'fee_international' => enrichment.fee_international,
            'fee_uk_eu' => enrichment.fee_uk_eu,
            'financial_support' => enrichment.financial_support,
            'how_school_placements_work' => enrichment.how_school_placements_work,
            'interview_process' => enrichment.interview_process,
            'other_requirements' => enrichment.other_requirements,
            'personal_qualities' => enrichment.personal_qualities,
            'required_qualifications' => enrichment.required_qualifications,
            'salary_details' => enrichment.salary_details,
            'about_accrediting_body' => nil,
            'english' => 'must_have_qualification_at_application_time',
            'maths' => 'must_have_qualification_at_application_time',
            'science' => 'must_have_qualification_at_application_time',
            'provider_code' => provider.provider_code,
            'recruitment_cycle_year' => current_year.to_s,
            'gcse_subjects_required' => %w[maths english science],
            'age_range_in_years' => course.age_range_in_years,
            'accrediting_provider' => nil,
            'accredited_body_code' => nil,
            'uuid' => course.uuid,
            'program_type' => course.program_type,
            'accept_pending_gcse' => course.accept_pending_gcse,
            'accept_gcse_equivalency' => course.accept_gcse_equivalency,
            'accept_english_gcse_equivalency' => course.accept_english_gcse_equivalency,
            'accept_maths_gcse_equivalency' => course.accept_maths_gcse_equivalency,
            'accept_science_gcse_equivalency' => course.accept_science_gcse_equivalency,
            'additional_gcse_equivalencies' => course.additional_gcse_equivalencies,
            'degree_grade' => course.degree_grade,
            'additional_degree_subject_requirements' => course.additional_degree_subject_requirements,
            'degree_subject_requirements' => course.degree_subject_requirements,
            'can_sponsor_skilled_worker_visa' => course.can_sponsor_skilled_worker_visa,
            'can_sponsor_student_visa' => course.can_sponsor_student_visa,
            'campaign_name' => course.campaign_name,
            'extended_qualification_descriptions' => 'Postgraduate certificate in education (PGCE) with qualified teacher status (QTS)'
          },
          'relationships' => {
            'accrediting_provider' => { 'meta' => { 'included' => false } },
            'provider' => { 'meta' => { 'included' => false } },
            'sites' => { 'data' => [{ 'type' => 'sites', 'id' => courses_site_status.site.id.to_s }] },
            'site_statuses' => { 'meta' => { 'included' => false } },
            'subjects' => { 'meta' => { 'included' => false } }
          }
        },
        'included' => [
          {
            'id' => courses_site_status.site.id.to_s,
            'type' => 'sites',
            'attributes' => {
              'code' => courses_site_status.site.code,
              'location_name' => courses_site_status.site.location_name,
              'address1' => courses_site_status.site.address1,
              'address2' => courses_site_status.site.address2,
              'address3' => courses_site_status.site.address3,
              'address4' => courses_site_status.site.address4,
              'postcode' => courses_site_status.site.postcode,
              'region_code' => courses_site_status.site.region_code,
              'latitude' => courses_site_status.site.latitude,
              'longitude' => courses_site_status.site.longitude,
              'urn' => courses_site_status.site.urn,
              'recruitment_cycle_year' => current_year.to_s
            }
          }
        ],
        'jsonapi' => {
          'version' => '1.0'
        }
      )
    end
  end

  def render_course(course)
    JSONAPI::Serializable::Renderer.new.render(
      course,
      class: {
        Course: API::V3::SerializableCourse
      }
    )
  end
end

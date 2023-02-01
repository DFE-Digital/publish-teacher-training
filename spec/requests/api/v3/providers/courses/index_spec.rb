# frozen_string_literal: true

require 'rails_helper'

describe 'GET v3/recruitment_cycle/:recruitment_cycle_year/providers/:provider_code/courses', :with_publish_constraint do
  subject { response }

  let(:course_subject_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }

  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_year)  { current_cycle.year.to_i }
  let(:previous_year) { current_year - 1 }
  let(:next_year)     { current_year + 1 }
  let(:subjects) { [course_subject_mathematics] }

  let(:applications_open_from) { Time.now.utc }
  let(:campaign_name) { nil }
  let(:findable_open_course) do
    create(:course, :resulting_in_pgce_with_qts, :with_apprenticeship, :with_gcse_equivalency,
           level: 'primary',
           name: 'Mathematics',
           provider:,
           start_date: Time.now.utc,
           study_mode: :full_time,
           subjects:,
           is_send: true,
           site_statuses: [courses_site_status],
           enrichments: [enrichment],
           maths: :must_have_qualification_at_application_time,
           english: :must_have_qualification_at_application_time,
           science: :must_have_qualification_at_application_time,
           age_range_in_years: '3_to_7',
           applications_open_from:,
           campaign_name:)
  end

  let(:courses_site_status) do
    build(:site_status,
          :findable,
          :with_any_vacancy,
          site: create(:site, provider:))
  end

  let(:enrichment)     { build(:course_enrichment, :published) }
  let(:provider)       { create(:provider) }

  let(:site_status)    { findable_open_course.site_statuses.first }
  let(:site)           { site_status.site }

  describe 'GET index' do
    def perform_request
      findable_open_course
      get request_path
      response
    end

    describe 'JSON generated for courses' do
      context 'with a specified provider' do
        subject { perform_request }

        let(:request_path) { "/api/v3/recruitment_cycles/#{current_cycle.year}/providers/#{provider.provider_code}/courses" }

        it { is_expected.to have_http_status(:success) }

        it 'has a data section with the correct attributes' do
          perform_request

          json_response = JSON.parse response.body

          changed_at = json_response['data'][0]['attributes'].delete('changed_at')
          expect(Time.zone.parse(changed_at)).to be_within(10).of(Time.zone.now)

          expect(json_response).to eq(
            'data' => [{
              'id' => provider.courses[0].id.to_s,
              'type' => 'courses',
              'attributes' => {
                'findable?' => true,
                'open_for_applications?' => true,
                'has_vacancies?' => true,
                'name' => provider.courses[0].name,
                'course_code' => provider.courses[0].course_code,
                'start_date' => provider.courses[0].start_date.strftime('%B %Y'),
                'study_mode' => 'full_time',
                'qualification' => 'pgce_with_qts',
                'description' => 'PGCE with QTS full time teaching apprenticeship',
                'content_status' => 'published',
                'ucas_status' => 'running',
                'funding_type' => 'apprenticeship',
                'is_send?' => true,
                'level' => 'primary',
                'applications_open_from' => provider.courses[0].applications_open_from.strftime('%Y-%m-%d'),
                'provider_type' => provider.provider_type,
                'about_course' => enrichment.about_course,
                'course_length' => enrichment.course_length,
                'fee_details' => enrichment.fee_details,
                'fee_international' => enrichment.fee_international,
                'fee_uk_eu' => enrichment.fee_uk_eu,
                'financial_support' => enrichment.financial_support,
                'how_school_placements_work' => enrichment.how_school_placements_work,
                'interview_process' => enrichment.interview_process,
                'other_requirements' => enrichment.other_requirements,
                'personal_qualities' => enrichment.personal_qualities,
                'required_qualifications' => enrichment.required_qualifications,
                'salary_details' => enrichment.salary_details,
                'last_published_at' => enrichment.last_published_timestamp_utc.iso8601,
                'about_accrediting_body' => nil,
                'english' => 'must_have_qualification_at_application_time',
                'maths' => 'must_have_qualification_at_application_time',
                'science' => 'must_have_qualification_at_application_time',
                'provider_code' => provider.provider_code,
                'recruitment_cycle_year' => current_year.to_s,
                'gcse_subjects_required' => %w[maths english science],
                'age_range_in_years' => provider.courses[0].age_range_in_years,
                'accrediting_provider' => nil,
                'accredited_body_code' => nil,
                'uuid' => provider.courses[0].uuid,
                'program_type' => provider.courses[0].program_type,
                'accept_pending_gcse' => provider.courses[0].accept_pending_gcse,
                'accept_gcse_equivalency' => provider.courses[0].accept_gcse_equivalency,
                'accept_english_gcse_equivalency' => provider.courses[0].accept_english_gcse_equivalency,
                'accept_maths_gcse_equivalency' => provider.courses[0].accept_maths_gcse_equivalency,
                'accept_science_gcse_equivalency' => provider.courses[0].accept_science_gcse_equivalency,
                'additional_gcse_equivalencies' => provider.courses[0].additional_gcse_equivalencies,
                'degree_grade' => provider.courses[0].degree_grade,
                'additional_degree_subject_requirements' => provider.courses[0].additional_degree_subject_requirements,
                'degree_subject_requirements' => provider.courses[0].degree_subject_requirements,
                'can_sponsor_skilled_worker_visa' => provider.courses[0].can_sponsor_skilled_worker_visa,
                'can_sponsor_student_visa' => provider.courses[0].can_sponsor_student_visa,
                'campaign_name' => provider.courses[0].campaign_name,
                'extended_qualification_descriptions' => 'Postgraduate certificate in education (PGCE) with qualified teacher status (QTS)'
              },
              'relationships' => {
                'accrediting_provider' => { 'meta' => { 'included' => false } },
                'provider' => { 'meta' => { 'included' => false } },
                'site_statuses' => { 'meta' => { 'included' => false } },
                'sites' => { 'meta' => { 'included' => false } },
                'subjects' => { 'meta' => { 'included' => false } }
              }
            }],
            'meta' => {
              'count' => 1
            },
            'jsonapi' => {
              'version' => '1.0'
            }
          )
        end

        context 'with a engineers_teach_physics campaign course' do
          let(:campaign_name) { 'engineers_teach_physics' }

          it "has the campaign_name 'engineers_teach_physics'" do
            findable_open_course

            perform_request
            json_response = JSON.parse response.body
            expect(json_response['data'].first)
              .to have_attribute('campaign_name').with_value('engineers_teach_physics')
          end
        end
      end
    end

    context "when the provider doesn't exist" do
      before do
        get("/api/v3/recruitment_cycles/#{current_year.year}/providers/non-existent-provider/courses")
      end

      it { is_expected.to have_http_status(:not_found) }
    end

    context 'when there is more than one provider' do
      let(:request_path) { "/api/v3/recruitment_cycles/#{current_cycle.year}/providers/#{provider.provider_code}/courses" }
      let(:another_provider) { create(:provider) }
      let(:another_course) { create(:course, provider: another_provider, site_statuses: [build(:site_status, :findable)]) }

      before do
        another_provider
        another_course
        perform_request
      end

      it "doesn't return the other providers course" do
        json_response = JSON.parse response.body
        courses = json_response['data']
        expect(courses.length).to eq(1)
        expect(courses.first['id'].to_s).not_to eq(another_course.id.to_s)
      end
    end

    context 'with two recruitment cycles' do
      let(:next_cycle) { create(:recruitment_cycle, :next) }
      let(:next_provider) do
        create(:provider,
               provider_code: provider.provider_code,
               recruitment_cycle: next_cycle)
      end
      let(:next_course) do
        create(:course,
               provider: next_provider,
               course_code: findable_open_course.course_code,
               site_statuses: [build(:site_status, :findable)])
      end

      describe 'making a request without specifying a recruitment cycle' do
        let(:request_path) { "/api/v3/recruitment_cycles/#{current_year.year}/providers/#{provider.provider_code}/courses" }

        it 'only returns data for the current recruitment cycle' do
          next_course
          findable_open_course

          perform_request

          json_response = JSON.parse response.body
          expect(json_response['data'].count).to eq 1
          expect(json_response['data'].first)
            .to have_attribute('recruitment_cycle_year').with_value(current_year.to_s)
        end
      end

      describe 'making a request for the next recruitment cycle' do
        let(:request_path) do
          "/api/v3/recruitment_cycles/#{next_cycle.year}" \
            "/providers/#{next_provider.provider_code}/courses"
        end

        it 'only returns data for the next recruitment cycle' do
          findable_open_course
          next_course

          perform_request

          json_response = JSON.parse response.body
          expect(json_response['data'].count).to eq 1
          expect(json_response['data'].first)
            .to have_attribute('recruitment_cycle_year').with_value(next_year.to_s)
        end
      end
    end
  end
end

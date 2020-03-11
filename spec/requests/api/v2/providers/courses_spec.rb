require "rails_helper"

describe "Courses API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:course_subject_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }

  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_year)  { current_cycle.year.to_i }
  let(:previous_year) { current_year - 1 }
  let(:next_year)     { current_year + 1 }
  let(:subjects) { [course_subject_mathematics] }

  let(:applications_open_from) { Time.now.utc }
  let(:findable_open_course) do
    create(:course, :resulting_in_pgce_with_qts, :with_apprenticeship,
           level: "primary",
           name: "Mathematics",
           provider: provider,
           start_date: Time.now.utc,
           study_mode: :full_time,
           subjects: subjects,
           is_send: true,
           site_statuses: courses_site_statuses,
           enrichments: [enrichment],
           maths: :must_have_qualification_at_application_time,
           english: :must_have_qualification_at_application_time,
           science: :must_have_qualification_at_application_time,
           age_range_in_years: "3_to_7",
           applications_open_from: applications_open_from)
  end

  let(:courses_site_statuses) {
    [
      build(:site_status,
            :findable,
            :with_any_vacancy,
            site: create(:site, provider: provider)),
      build(:site_status,
            :with_no_vacancies,
            site: create(:site, provider: provider)),
    ]
  }
  let(:enrichment)     { build :course_enrichment, :published }
  let(:provider)       { create :provider, organisations: [organisation] }

  let(:site_status1)   { findable_open_course.site_statuses.first }
  let(:site_status2)   { findable_open_course.site_statuses.last }
  let(:site1)          { site_status1.site }
  let(:site2)          { site_status2.site }

  subject { response }

  describe "GET show" do
    let(:get_params) { { include: "subjects,site_statuses.site" } }
    let(:show_path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}"
    end

    subject do
      get show_path,
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: get_params
      response
    end

    context "with a findable_open_course" do
      let(:course) { findable_open_course }

      include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

      describe "JSON generated for courses" do
        it { should have_http_status(:success) }

        it "has a data section with the correct attributes" do
          json_response = JSON.parse subject.body
          expect(json_response).to eq(
            "data" => {
              "id" => provider.courses[0].id.to_s,
              "type" => "courses",
              "attributes" => {
                "findable?" => true,
                "open_for_applications?" => true,
                "has_vacancies?" => true,
                "name" => provider.courses[0].name,
                "course_code" => provider.courses[0].course_code,
                "start_date" => provider.courses[0].start_date.strftime("%B %Y"),
                "study_mode" => "full_time",
                "qualification" => "pgce_with_qts",
                "description" => "PGCE with QTS full time teaching apprenticeship",
                "content_status" => "published",
                "ucas_status" => "running",
                "funding_type" => "apprenticeship",
                "is_send?" => true,
                "level" => "primary",
                "applications_open_from" =>
                  findable_open_course.applications_open_from.to_s,
                "about_course" => enrichment.about_course,
                "course_length" => enrichment.course_length,
                "fee_details" => enrichment.fee_details,
                "fee_international" => enrichment.fee_international,
                "fee_uk_eu" => enrichment.fee_uk_eu,
                "financial_support" => enrichment.financial_support,
                "how_school_placements_work" => enrichment.how_school_placements_work,
                "interview_process" => enrichment.interview_process,
                "other_requirements" => enrichment.other_requirements,
                "personal_qualities" => enrichment.personal_qualities,
                "required_qualifications" => enrichment.required_qualifications,
                "salary_details" => enrichment.salary_details,
                "last_published_at" => enrichment.last_published_timestamp_utc.iso8601,
                "about_accrediting_body" => nil,
                "english" => "must_have_qualification_at_application_time",
                "maths" => "must_have_qualification_at_application_time",
                "science" => "must_have_qualification_at_application_time",
                "provider_code" => provider.provider_code,
                "recruitment_cycle_year" => current_year.to_s,
                "gcse_subjects_required" => %w[maths english science],
                "age_range_in_years" => provider.courses[0].age_range_in_years,
                "accrediting_provider" => nil,
                "accrediting_provider_code" => nil,
              },
              "relationships" => {
                "accrediting_provider" => { "meta" => { "included" => false } },
                "provider" => { "meta" => { "included" => false } },
                "sites" => { "meta" => { "included" => false } },
                "site_statuses" => {
                  "data" => [
                    { "type" => "site_statuses", "id" => site_status1.id.to_s },
                    { "type" => "site_statuses", "id" => site_status2.id.to_s },
                  ],
                },
                "subjects" => { "data" => [{ "type" => "subjects", "id" => course_subject_mathematics.id.to_s }] },
              },
              "meta" => {
                "edit_options" => {
                  "entry_requirements" => %w[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test],
                  "qualifications" => %w[qts pgce_with_qts pgde_with_qts],
                  "age_range_in_years" => %w[3_to_7 5_to_11 7_to_11 7_to_14],
                  "start_dates" => [
                    "October #{previous_year}",
                    "November #{previous_year}",
                    "December #{previous_year}",
                    "January #{current_year}",
                    "February #{current_year}",
                    "March #{current_year}",
                    "April #{current_year}",
                    "May #{current_year}",
                    "June #{current_year}",
                    "July #{current_year}",
                    "August #{current_year}",
                    "September #{current_year}",
                    "October #{current_year}",
                    "November #{current_year}",
                    "December #{current_year}",
                    "January #{next_year}",
                    "February #{next_year}",
                    "March #{next_year}",
                    "April #{next_year}",
                    "May #{next_year}",
                    "June #{next_year}",
                    "July #{next_year}",
                  ],
                  "study_modes" => %w[full_time part_time full_time_or_part_time],
                  "show_is_send" => false,
                  "show_start_date" => false,
                  "show_applications_open" => false,
                  "subjects" => [
                     {
                       "id" => "1",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary",
                         "subject_code" => "00",
                         "bursary_amount" => nil,
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => nil,
                       },
                     },
                     {
                       "id" => "2",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary with English",
                         "subject_code" => "01",
                         "bursary_amount" => nil,
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => nil,
                       },
                     },
                     {
                       "id" => "3",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary with geography and history",
                         "subject_code" => "02",
                         "bursary_amount" => nil,
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => nil,
                       },
                     },
                     {
                       "id" => "4",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary with mathematics",
                         "subject_code" => "03",
                         "bursary_amount" => "6000",
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => true,
                       },
                     },
                     {
                       "id" => "5",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary with modern languages",
                         "subject_code" => "04",
                         "bursary_amount" => nil,
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => nil,
                       },
                     },
                     {
                       "id" => "6",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary with physical education",
                         "subject_code" => "06",
                         "bursary_amount" => nil,
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => nil,
                       },
                     },
                     {
                       "id" => "7",
                       "type" => "subjects",
                       "attributes" => {
                         "subject_name" => "Primary with science",
                         "subject_code" => "07",
                         "bursary_amount" => nil,
                         "early_career_payments" => nil,
                         "scholarship" => nil,
                         "subject_knowledge_enhancement_course_available" => nil,
                       },
                     },
                  ],
                  "modern_languages" => [
                 {
                   "id" => "34",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "French",
                     "subject_code" => "15",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => "28000",
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "35",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "English as a second or other language",
                     "subject_code" => "16",
                     "bursary_amount" => nil,
                     "early_career_payments" => nil,
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => nil,
                   },
                 },
                 {
                   "id" => "36",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "German",
                     "subject_code" => "17",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => "28000",
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "37",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Italian",
                     "subject_code" => "18",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "38",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Japanese",
                     "subject_code" => "19",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "39",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Mandarin",
                     "subject_code" => "20",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "40",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Russian",
                     "subject_code" => "21",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "41",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Spanish",
                     "subject_code" => "22",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => "28000",
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
                 {
                   "id" => "42",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Modern languages (other)",
                     "subject_code" => "24",
                     "bursary_amount" => "26000",
                     "early_career_payments" => "2000",
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => true,
                   },
                 },
               ],
                  "modern_languages_subject" => {
                   "id" => "33",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Modern Languages",
                     "subject_code" => nil,
                     "bursary_amount" => nil,
                     "early_career_payments" => nil,
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => nil,
                   },
                 },
                },
              },
            },
            "jsonapi" => {
              "version" => "1.0",
            },
            "included" => [
              {
                "id" => site_status1.id.to_s,
                "type" => "site_statuses",
                "attributes" => {
                  "vac_status" => site_status1.vac_status,
                  "publish" => site_status1.publish,
                  "status" => site_status1.status,
                  "has_vacancies?" => true,
                },
                "relationships" => {
                  "site" => {
                    "data" => {
                      "type" => "sites",
                      "id" => site1.id.to_s,
                    },
                  },
                },
              },
              {
                "id" => site_status2.id.to_s,
                "type" => "site_statuses",
                "attributes" => {
                  "vac_status" => site_status2.vac_status,
                  "publish" => site_status2.publish,
                  "status" => site_status2.status,
                  "has_vacancies?" => false,
                },
                "relationships" => {
                  "site" => {
                    "data" => {
                      "type" => "sites",
                      "id" => site2.id.to_s,
                    },
                  },
                },
              },
              {
                "id" => course_subject_mathematics.id.to_s,
                "type" => "subjects",
                "attributes" => {
                  "subject_name" => course_subject_mathematics.subject_name,
                  "subject_code" => course_subject_mathematics.subject_code,
                  "bursary_amount" => "6000",
                  "early_career_payments" => nil,
                  "scholarship" => nil,
                  "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => site1.id.to_s,
                "type" => "sites",
                "attributes" => {
                  "code" => site1.code,
                  "location_name" => site1.location_name,
                  "address1" => site1.address1,
                  "address2" => site1.address2,
                  "address3" => site1.address3,
                  "address4" => site1.address4,
                  "postcode" => site1.postcode,
                  "region_code" => site1.region_code,
                  "latitude" => site1.latitude,
                  "longitude" => site1.longitude,
                  "recruitment_cycle_year" => current_year.to_s,
                },
              },
              {
                "id" => site2.id.to_s,
                "type" => "sites",
                "attributes" => {
                  "code" => site2.code,
                  "location_name" => site2.location_name,
                  "address1" => site2.address1,
                  "address2" => site2.address2,
                  "address3" => site2.address3,
                  "address4" => site2.address4,
                  "postcode" => site2.postcode,
                  "region_code" => site2.region_code,
                  "latitude" => site2.latitude,
                  "longitude" => site2.longitude,
                  "recruitment_cycle_year" => current_year.to_s,
                },
              },
            ],
          )
        end
      end
    end

    context "when course and provider is not related" do
      let(:course) { create(:course) }

      it { should have_http_status(:not_found) }
    end

    context "when a course is discarded" do
      let(:course) do
        course = create(:course, provider: provider)
        create(:site_status, :new, site: create(:site), course: course)
        course.discard
        course
      end

      it { should have_http_status(:not_found) }
    end

    context "when the course is a modern languages secondary course" do
      let(:course) do
        findable_open_course.subjects = [
          find_or_create(:secondary_subject, :modern_languages),
          find_or_create(:modern_languages_subject, :italian),
        ]
        findable_open_course.level = "secondary"
        findable_open_course.save!
        findable_open_course
      end

      it "has the correct edit options for the modern languages" do
        json_response = JSON.parse subject.body
        expect(json_response["data"]["meta"]["edit_options"]["modern_languages"]).to(
          eq(
            [
              {
                "id" => "34",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "French",
                 "subject_code" => "15",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => "28000",
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "35",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "English as a second or other language",
                 "subject_code" => "16",
                 "bursary_amount" => nil,
                 "early_career_payments" => nil,
                 "scholarship" => nil,
                 "subject_knowledge_enhancement_course_available" => nil,
                },
              },
              {
                "id" => "36",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "German",
                 "subject_code" => "17",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => "28000",
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "37",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "Italian",
                 "subject_code" => "18",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => nil,
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "38",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "Japanese",
                 "subject_code" => "19",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => nil,
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "39",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "Mandarin",
                 "subject_code" => "20",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => nil,
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "40",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "Russian",
                 "subject_code" => "21",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => nil,
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "41",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "Spanish",
                 "subject_code" => "22",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => "28000",
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
              {
                "id" => "42",
                "type" => "subjects",
                "attributes" => {
                 "subject_name" => "Modern languages (other)",
                 "subject_code" => "24",
                 "bursary_amount" => "26000",
                 "early_career_payments" => "2000",
                 "scholarship" => nil,
                 "subject_knowledge_enhancement_course_available" => true,
                },
              },
            ],
          ),
        )
      end
    end
  end

  describe "GET index" do
    context "when unauthenticated" do
      let(:payload) { { email: "foo@bar" } }

      before do
        get "/api/v2/providers/#{provider.provider_code}/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials }
      end

      it { should have_http_status(:unauthorized) }
    end

    context "when unauthorised" do
      let(:unauthorised_user) { create(:user) }
      let(:payload) { { email: unauthorised_user.email } }

      it "raises an error" do
        expect {
          get "/api/v2/providers/#{provider.provider_code}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    def perform_request
      findable_open_course
      get request_path,
          headers: { "HTTP_AUTHORIZATION" => credentials }
      response
    end

    describe "JSON generated for courses" do
      let(:request_path) { "/api/v2/providers/#{provider.provider_code}/courses" }

      subject { perform_request }

      it { should have_http_status(:success) }

      it "has a data section with the correct attributes" do
        perform_request

        json_response = JSON.parse response.body
        expect(json_response).to eq(
          "data" => [{
            "id" => provider.courses[0].id.to_s,
            "type" => "courses",
            "attributes" => {
              "findable?" => true,
              "open_for_applications?" => true,
              "has_vacancies?" => true,
              "name" => provider.courses[0].name,
              "course_code" => provider.courses[0].course_code,
              "start_date" => provider.courses[0].start_date.strftime("%B %Y"),
              "study_mode" => "full_time",
              "qualification" => "pgce_with_qts",
              "description" => "PGCE with QTS full time teaching apprenticeship",
              "content_status" => "published",
              "ucas_status" => "running",
              "funding_type" => "apprenticeship",
              "is_send?" => true,
              "level" => "primary",
              "applications_open_from" => provider.courses[0].applications_open_from.strftime("%Y-%m-%d"),
              "about_course" => enrichment.about_course,
              "course_length" => enrichment.course_length,
              "fee_details" => enrichment.fee_details,
              "fee_international" => enrichment.fee_international,
              "fee_uk_eu" => enrichment.fee_uk_eu,
              "financial_support" => enrichment.financial_support,
              "how_school_placements_work" => enrichment.how_school_placements_work,
              "interview_process" => enrichment.interview_process,
              "other_requirements" => enrichment.other_requirements,
              "personal_qualities" => enrichment.personal_qualities,
              "required_qualifications" => enrichment.required_qualifications,
              "salary_details" => enrichment.salary_details,
              "last_published_at" => enrichment.last_published_timestamp_utc.iso8601,
              "about_accrediting_body" => nil,
              "english" => "must_have_qualification_at_application_time",
              "maths" => "must_have_qualification_at_application_time",
                "science" => "must_have_qualification_at_application_time",
              "provider_code" => provider.provider_code,
              "recruitment_cycle_year" => current_year.to_s,
              "gcse_subjects_required" => %w[maths english science],
              "age_range_in_years" => provider.courses[0].age_range_in_years,
              "accrediting_provider" => nil,
              "accrediting_provider_code" => nil,
            },
            "relationships" => {
              "accrediting_provider" => { "meta" => { "included" => false } },
              "provider" => { "meta" => { "included" => false } },
              "site_statuses" => { "meta" => { "included" => false } },
              "sites" => { "meta" => { "included" => false } },
              "subjects" => { "meta" => { "included" => false } },
            },
            "meta" => {
              "edit_options" => {
                "entry_requirements" => %w[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test],
                "qualifications" => %w[qts pgce_with_qts pgde_with_qts],
                "age_range_in_years" => %w[3_to_7 5_to_11 7_to_11 7_to_14],
                "start_dates" => [
                  "October #{previous_year}",
                  "November #{previous_year}",
                  "December #{previous_year}",
                  "January #{current_year}",
                  "February #{current_year}",
                  "March #{current_year}",
                  "April #{current_year}",
                  "May #{current_year}",
                  "June #{current_year}",
                  "July #{current_year}",
                  "August #{current_year}",
                  "September #{current_year}",
                  "October #{current_year}",
                  "November #{current_year}",
                  "December #{current_year}",
                  "January #{next_year}",
                  "February #{next_year}",
                  "March #{next_year}",
                  "April #{next_year}",
                  "May #{next_year}",
                  "June #{next_year}",
                  "July #{next_year}",
                ],
                "study_modes" => %w[full_time part_time full_time_or_part_time],
                "show_is_send" => false,
                "show_start_date" => false,
                "show_applications_open" => false,
                "subjects" => [
                  {
                    "id" => "1",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary",
                      "subject_code" => "00",
                      "bursary_amount" => nil,
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => nil,
                    },
                  },
                  {
                    "id" => "2",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary with English",
                      "subject_code" => "01",
                      "bursary_amount" => nil,
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => nil,
                    },
                  },
                  {
                    "id" => "3",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary with geography and history",
                      "subject_code" => "02",
                      "bursary_amount" => nil,
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => nil,
                    },
                  },
                  {
                    "id" => "4",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary with mathematics",
                      "subject_code" => "03",
                      "bursary_amount" => "6000",
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => true,
                    },
                  },
                  {
                    "id" => "5",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary with modern languages",
                      "subject_code" => "04",
                      "bursary_amount" => nil,
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => nil,
                    },
                  },
                  {
                    "id" => "6",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary with physical education",
                      "subject_code" => "06",
                      "bursary_amount" => nil,
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => nil,
                    },
                  },
                  {
                    "id" => "7",
                    "type" => "subjects",
                    "attributes" => {
                      "subject_name" => "Primary with science",
                      "subject_code" => "07",
                      "bursary_amount" => nil,
                      "early_career_payments" => nil,
                      "scholarship" => nil,
                      "subject_knowledge_enhancement_course_available" => nil,
                    },
                  },
                ],
                "modern_languages" => [
                    {
                      "id" => "34",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "French",
                        "subject_code" => "15",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => "28000",
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "35",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "English as a second or other language",
                        "subject_code" => "16",
                        "bursary_amount" => nil,
                        "early_career_payments" => nil,
                        "scholarship" => nil,
                        "subject_knowledge_enhancement_course_available" => nil,
                      },
                    },
                    {
                      "id" => "36",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "German",
                        "subject_code" => "17",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => "28000",
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "37",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "Italian",
                        "subject_code" => "18",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => nil,
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "38",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "Japanese",
                        "subject_code" => "19",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => nil,
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "39",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "Mandarin",
                        "subject_code" => "20",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => nil,
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "40",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "Russian",
                        "subject_code" => "21",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => nil,
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "41",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "Spanish",
                        "subject_code" => "22",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => "28000",
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                    {
                      "id" => "42",
                      "type" => "subjects",
                      "attributes" => {
                        "subject_name" => "Modern languages (other)",
                        "subject_code" => "24",
                        "bursary_amount" => "26000",
                        "early_career_payments" => "2000",
                        "scholarship" => nil,
                        "subject_knowledge_enhancement_course_available" => true,
                      },
                    },
                  ],
                 "modern_languages_subject" => {
                   "id" => "33",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Modern Languages",
                     "subject_code" => nil,
                     "bursary_amount" => nil,
                     "early_career_payments" => nil,
                     "scholarship" => nil,
                     "subject_knowledge_enhancement_course_available" => nil,
                   },
                 },
              },
            },
          }],
          "jsonapi" => {
            "version" => "1.0",
          },
        )
      end
    end

    context "when the provider doesn't exist" do
      before do
        get("/api/v2/providers/non-existent-provider/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials })
      end

      it { should have_http_status(:not_found) }
    end

    context "with two recruitment cycles" do
      let(:next_cycle) { create :recruitment_cycle, :next }
      let(:next_provider) {
        create :provider,
               organisations: [organisation],
               provider_code: provider.provider_code,
               recruitment_cycle: next_cycle
      }
      let(:next_course) {
        create :course,
               provider: next_provider,
               course_code: findable_open_course.course_code
      }

      describe "making a request without specifying a recruitment cycle" do
        let(:request_path) { "/api/v2/providers/#{provider.provider_code}/courses" }

        it "only returns data for the current recruitment cycle" do
          next_course
          findable_open_course

          perform_request

          json_response = JSON.parse response.body
          expect(json_response["data"].count).to eq 1
          expect(json_response["data"].first)
            .to have_attribute("recruitment_cycle_year").with_value(current_year.to_s)
        end
      end

      describe "making a request for the next recruitment cycle" do
        let(:request_path) {
          "/api/v2/recruitment_cycles/#{next_cycle.year}" \
          "/providers/#{next_provider.provider_code}/courses"
        }

        it "only returns data for the next recruitment cycle" do
          findable_open_course
          next_course

          perform_request

          json_response = JSON.parse response.body
          expect(json_response["data"].count).to eq 1
          expect(json_response["data"].first)
            .to have_attribute("recruitment_cycle_year").with_value(next_year.to_s)
        end
      end
    end
  end

  describe "DELETE destroy" do
    let(:path) do
      "/api/v2/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}"
    end

    let(:course) { create(:course, provider: provider, site_statuses: [site_status]) }
    let(:site_status) { build(:site_status, :new) }

    before do
      course
    end

    subject do
      delete path, headers: { "HTTP_AUTHORIZATION" => credentials }
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context "when course and provider is not related" do
      let(:course) { create(:course) }

      it { should have_http_status(:not_found) }
    end

    describe "when authorized" do
      it { should have_http_status(:success) }
    end
  end

  describe "POST withdraw" do
    let(:path) do
      "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/withdraw"
    end

    let(:course) { create(:course, provider: provider, site_statuses: [site_status1, site_status2, site_status3], enrichments: [enrichment]) }
    let(:enrichment) { build(:course_enrichment) }
    let(:site_status1) { build(:site_status, :running, :published, :full_time_vacancies, site: site) }
    let(:site_status2) { build(:site_status, :new, :full_time_vacancies, site: site) }
    let(:site_status3) { build(:site_status, :suspended, :with_no_vacancies, site: site) }
    let(:site) { build(:site, provider: provider) }
    let(:post_withdraw) { post path, headers: { "HTTP_AUTHORIZATION" => credentials } }

    before do
      course
    end

    subject do
      post_withdraw
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context "when the course has been published" do
      let(:enrichment) { build(:course_enrichment, :published) }

      it { should have_http_status(:success) }

      it "should have updated the courses site statuses to be suspended and have no vacancies" do
        post_withdraw

        expect(site_status1.reload.vac_status).to eq("no_vacancies")
        expect(site_status1.reload.status).to eq("suspended")
        expect(site_status2.reload.vac_status).to eq("no_vacancies")
        expect(site_status2.reload.status).to eq("suspended")
        expect(site_status3.reload.vac_status).to eq("no_vacancies")
        expect(site_status3.reload.status).to eq("suspended")
      end

      it "should no longer be findable" do
        post_withdraw

        expect(course.reload.findable?).to be_falsey
      end
    end

    context "when the course has not been published" do
      let(:enrichment) { build(:course_enrichment) }

      it "should raise an error" do
        expect { post_withdraw }.to raise_error("This course has not been published and should be deleted not withdrawn")
      end
    end
  end
end

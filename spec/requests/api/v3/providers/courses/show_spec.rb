require "rails_helper"

describe "GET v3/providers/:provider_code/courses/:course_code" do
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:next_cycle)    { find_or_create :recruitment_cycle, :next }
  let(:current_year)  { current_cycle.year.to_i }
  let(:previous_year) { current_year - 1 }
  let(:next_year)     { current_year + 1 }
  let(:provider) { create :provider, recruitment_cycle: current_cycle }
  let(:courses_site_status) {
    build(:site_status,
          :findable,
          :full_time_vacancies,
          site: create(:site, provider: provider))
  }

  let(:jsonapi_course) {
    JSON.parse(
      JSONAPI::Serializable::Renderer.new.render(
        course,
        class: {
          Course: API::V2::SerializableCourse,
        },
      ).to_json,
    )
  }
  let(:jsonapi_response) { JSON.parse(response.body) }
  let(:route) {
    "/api/v3/recruitment_cycles/#{current_year}" \
    "/providers/#{provider.provider_code}" \
    "/courses/#{course.course_code}"
  }
  let(:course) {
    create :course,
           provider: provider,
           enrichments: enrichments,
           site_statuses: [courses_site_status],
           applications_open_from: Time.now.utc
  }

  context "with a published course" do
    let(:enrichments) { [build(:course_enrichment, :published)] }

    it "returns full course information" do
      get route

      expect(jsonapi_response["data"]).to eq jsonapi_course["data"]
    end

    it "returns sparse course information" do
      requested_fields = %w[course_code name provider_code].sort
      get route + "?fields[courses]=#{requested_fields.join(',')}"

      expect(jsonapi_response["data"]["attributes"].keys).to eq requested_fields
    end
  end

  context "with a course with no enrichments" do
    let(:enrichments) { [] }

    it "returns nil course information" do
      get route

      expect(jsonapi_response["data"]).to eq nil
    end
  end

  context "with a course with a draft enrichment" do
    let(:enrichments) { [build(:course_enrichment, :initial_draft)] }

    it "returns nil course information" do
      get route

      expect(jsonapi_response["data"]).to eq nil
    end
  end

  context "with sites included" do
    let(:enrichments) { [build(:course_enrichment, :published)] }
    let(:enrichment) { course.enrichments.last }
    before do
      get "/api/v3/recruitment_cycles/#{current_year}" \
          "/providers/#{provider.provider_code.downcase}" \
          "/courses/#{course.course_code.downcase}",
          params: { include: "sites" }
    end

    it "has a data section with the correct attributes" do
      json_response = JSON.parse response.body
      expect(json_response).to eq(
        "data" => {
          "id" => course.id.to_s,
          "type" => "courses",
          "attributes" => {
            "findable?" => true,
            "open_for_applications?" => true,
            "has_vacancies?" => true,
            "name" => course.name,
            "course_code" => course.course_code,
            "start_date" => course.start_date.strftime("%B %Y"),
            "study_mode" => "full_time",
            "qualification" => "pgce_with_qts",
            "description" => "PGCE with QTS full time teaching apprenticeship",
            "content_status" => "published",
            "ucas_status" => "running",
            "funding_type" => "apprenticeship",
            "is_send?" => false,
            "level" => "primary",
            "applications_open_from" =>
              course.applications_open_from.to_s,
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
            "has_bursary?" => false,
            "has_scholarship_and_bursary?" => false,
            "has_early_career_payments?" => false,
            "bursary_amount" => nil,
            "scholarship_amount" => nil,
            "about_accrediting_body" => nil,
            "english" => "must_have_qualification_at_application_time",
            "maths" => "must_have_qualification_at_application_time",
            "science" => "must_have_qualification_at_application_time",
            "provider_code" => provider.provider_code,
            "recruitment_cycle_year" => current_year.to_s,
            "gcse_subjects_required" => %w[maths english science],
            "age_range_in_years" => course.age_range_in_years,
            "accrediting_provider" => nil,
            "accrediting_provider_code" => nil,
          },
          "relationships" => {
            "accrediting_provider" => { "meta" => { "included" => false } },
            "provider" => { "meta" => { "included" => false } },
            "sites" => { "data" => [{ "type" => "sites", "id" => courses_site_status.site.id.to_s }] },
            "site_statuses" => { "meta" => { "included" => false } },
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
                   },
                 },
                 {
                   "id" => "2",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Primary with English",
                     "subject_code" => "01",
                   },
                 },
                 {
                   "id" => "3",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Primary with geography and history",
                     "subject_code" => "02",
                   },
                 },
                 {
                   "id" => "4",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Primary with mathematics",
                     "subject_code" => "03",
                   },
                 },
                 {
                   "id" => "5",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Primary with modern languages",
                     "subject_code" => "04",
                   },
                 },
                 {
                   "id" => "6",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Primary with physical education",
                     "subject_code" => "06",
                   },
                 },
                 {
                   "id" => "7",
                   "type" => "subjects",
                   "attributes" => {
                     "subject_name" => "Primary with science",
                     "subject_code" => "07",
                   },
                 },
              ],
              "modern_languages" => nil,
            },
          },
        },
        "included" => [
          {
            "id" => courses_site_status.site.id.to_s,
            "type" => "sites",
            "attributes" => {
              "code" => courses_site_status.site.code,
              "location_name" => courses_site_status.site.location_name,
              "address1" => courses_site_status.site.address1,
              "address2" => courses_site_status.site.address2,
              "address3" => courses_site_status.site.address3,
              "address4" => courses_site_status.site.address4,
              "postcode" => courses_site_status.site.postcode,
              "region_code" => courses_site_status.site.region_code,
              "recruitment_cycle_year" => current_year.to_s,
            },
          },
        ],
        "jsonapi" => {
          "version" => "1.0",
        },
      )
    end
  end

  def render_course(course)
    JSONAPI::Serializable::Renderer.new.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )
  end
end

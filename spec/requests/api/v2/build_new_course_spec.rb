require "rails_helper"

describe '/api/v2/build_new_course', type: :request do
  let(:user) { create(:user, organisations: [organisation]) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation)      { create :organisation }
  let(:provider) do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle
  end
  let(:payload) { { email: user.email } }
  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  context 'with no parameters' do
    let(:params) { { course: {} } }

    it 'returns a blank course, a bunch of errors and loads of edit_options' do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      # puts json_response # use this to get updated expected response for the below
      # use rake lint and vim to tidy it up
      expected = {
        "course" =>
         { "id" => nil,
           "age_range" => nil,
           "course_code" => nil,
           "name" => nil,
           "profpost_flag" => nil,
           "program_type" => nil,
           "qualification" => nil,
           "start_date" => nil,
           "study_mode" => nil,
           "accrediting_provider_id" => nil,
           "provider_id" => provider.id,
           "modular" => "",
           "english" => nil,
           "maths" => nil,
           "science" => nil,
           "created_at" => nil,
           "updated_at" => nil,
           "changed_at" => nil,
           "accrediting_provider_code" => nil,
           "discarded_at" => nil,
           "age_range_in_years" => nil,
           "applications_open_from" => nil,
           "is_send" => false },
         "errors" => {
           "maths" => ["^Pick an option for Maths"],
           "english" => ["^Pick an option for English"],
           "enrichments" => []
         },
         "edit_options" => {
           "entry_requirements" => %w[must_have_qualification_at_application_time
                                      expect_to_achieve_before_training_begins
                                      equivalence_test],
           "qualifications" => %w[qts pgce_with_qts pgde_with_qts],
           "age_range_in_years" => %w[11_to_16 11_to_18 14_to_19],
           "start_dates" => ["August 2019",
                             "September 2019",
                             "October 2019",
                             "November 2019",
                             "December 2019",
                             "January 2020",
                             "February 2020",
                             "March 2020",
                             "April 2020",
                             "May 2020",
                             "June 2020",
                             "July 2020"],
           "study_modes" => %w[full_time part_time full_time_or_part_time],
           "program_type" => %w[pg_teaching_apprenticeship
                                higher_education_programme],
           "show_is_send" => true,
           "show_start_date" => true,
           "show_applications_open" => true
         }
      }

      expect(json_response).to eq expected
    end
  end

  context 'with enough attributes set in query parameters to make a valid course' do
    let(:params) do
      { course: {
        name: 'Foo Bar Course',
        maths: 'must_have_qualification_at_application_time',
        english: 'must_have_qualification_at_application_time',
        # todo: why is this valid when level not set? A: because level has a default. What to do about that if anything?
      } }
    end

    it 'returns the course model and edit_options with no errors' do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      # puts json_response # use this to get updated expected response for the below
      # use rake lint and vim to tidy it up
      expected = {
        "course" =>
          { "id" => nil,
            "age_range" => nil,
            "course_code" => nil,
            "name" => "Foo Bar Course",
            "profpost_flag" => nil,
            "program_type" => nil,
            "qualification" => nil,
            "start_date" => nil,
            "study_mode" => nil,
            "accrediting_provider_id" => nil,
            "provider_id" => provider.id,
            "modular" => "",
            "english" => "must_have_qualification_at_application_time",
            "maths" => "must_have_qualification_at_application_time",
            "science" => nil,
            "created_at" => nil,
            "updated_at" => nil,
            "changed_at" => nil,
            "accrediting_provider_code" => nil,
            "discarded_at" => nil,
            "age_range_in_years" => nil,
            "applications_open_from" => nil,
            "is_send" => false },
        "errors" => {
          "enrichments" => []
        },
        "edit_options" => {
          "entry_requirements" => %w[must_have_qualification_at_application_time
                                     expect_to_achieve_before_training_begins
                                     equivalence_test],
          "qualifications" => %w[qts pgce_with_qts pgde_with_qts],
          "age_range_in_years" => %w[11_to_16 11_to_18 14_to_19],
          "start_dates" => ["August 2019",
                            "September 2019",
                            "October 2019",
                            "November 2019",
                            "December 2019",
                            "January 2020",
                            "February 2020",
                            "March 2020",
                            "April 2020",
                            "May 2020",
                            "June 2020",
                            "July 2020"],
          "study_modes" => %w[full_time part_time full_time_or_part_time],
          "program_type" => %w[pg_teaching_apprenticeship
                               higher_education_programme],
          "show_is_send" => true,
          "show_start_date" => true,
          "show_applications_open" => true
        }
      }

      expect(json_response).to eq expected
    end
  end

  def do_get(params)
    get "/api/v2/build_new_course?year=#{recruitment_cycle.year}" \
          "&provider_code=#{provider.provider_code}",
        headers: { 'HTTP_AUTHORIZATION' => credentials },
        params: params
    response
  end

  def parse_response(response)
    JSON.parse(response.body)
  end
end

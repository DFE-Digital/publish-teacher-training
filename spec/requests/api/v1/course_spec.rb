require "rails_helper"

def get_course_codes_from_body(body)
  json = JSON.parse(body)
  json.map { |course| course["course_code"] }
end

RSpec.describe "Courses API", type: :request do
  describe 'GET index' do
    let(:credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials('bats')
    end
    let(:unauthorized_credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials('foo')
    end

    let(:provider) do
      FactoryBot.create(:provider,
        provider_name: "ACME SCITT",
        provider_code: "2LD",
        provider_type: "SCITT",
        site_count: 0,
        course_count: 0,
        scheme_member: 'Y',
        enrichments: [])
    end

    before do
      site = FactoryBot.create(:site, code: "-", location_name: "Main Site", provider: provider)
      subject1 = FactoryBot.create(:subject, subject_code: "1", subject_name: "Secondary")
      subject2 = FactoryBot.create(:subject, subject_code: "2", subject_name: "Mathematics")

      course = FactoryBot.create(:course,
        course_code: "2HPF",
        start_date: Date.new(2019, 9, 1),
        name: "Religious Education",
        qualification: 1,
        sites: [site],
        subjects: [subject1, subject2],
        study_mode: "full time",
        age_range: 'primary',
        english: 3,
        maths: 9,
        profpost_flag: "Postgraduate",
        program_type: "School Direct training programme",
        modular: "",
        provider: provider,
        age: 2.hours.ago)

      course.site_statuses.first.update(
        vac_status: 'Full time vacancies',
        publish: 'Y',
        status: 'Running',
        applications_accepted_from: "2018-10-09 00:00:00"
      )
    end

    context "without changed_since parameter" do
      it "returns http success" do
        get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => credentials }
        expect(response).to have_http_status(:success)
      end

      it "returns http unauthorised" do
        get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => unauthorized_credentials }
        expect(response).to have_http_status(:unauthorized)
      end

      it "JSON body response contains expected course attributes" do
        get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => credentials }

        json = JSON.parse(response.body)
        expect(json). to eq([
          {
            "course_code" => "2HPF",
            "start_month" => "2019-09-01T00:00:00Z",
            "start_month_string" => "September",
            "name" => "Religious Education",
            "study_mode" => "F",
            "copy_form_required" => "Y",
            "profpost_flag" => "PG",
            "program_type" => "SD",
            "age_range" => "P",
            "modular" => "",
            "english" => 3,
            "maths" => 9,
            "science" => nil,
            "qualification" => 1,
            "recruitment_cycle" => "2019",
            "campus_statuses" => [
              {
                "campus_code" => "-",
                "name" => "Main Site",
                "vac_status" => "F",
                "publish" => "Y",
                "status" => "R",
                "course_open_date" => "2018-10-09",
                "recruitment_cycle" => "2019"
              }
            ],
            "subjects" => [
              {
                "subject_code" => "1",
                "subject_name" => "Secondary"
              },
              {
                "subject_code" => "2",
                "subject_name" => "Mathematics"
              }
            ],
            "provider" => {
              "institution_code" => "2LD",
              "institution_name" => "ACME SCITT",
              "institution_type" => "B",
              "accrediting_provider" => 'N',
              "scheme_member" => "Y"
            },
            "accrediting_provider" => nil
          }
        ])
      end
    end

    context "with changed_since parameter" do
      describe "JSON body response" do
        it 'contains expected courses' do
          old_course = create(:course, course_code: "SINCE1", age: 1.hour.ago)
          updated_course = create(:course, course_code: "SINCE2", age: 5.minutes.ago)

          get '/api/v1/courses',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 10.minutes.ago.utc.iso8601 }

          returned_course_codes = get_course_codes_from_body(response.body)

          expect(returned_course_codes).not_to include old_course.course_code
          expect(returned_course_codes).to include updated_course.course_code
        end
      end

      it 'includes correct next link in response headers' do
        create(:course, course_code: "LAST1", age: 10.minutes.ago, provider: provider)

        timestamp_of_last_course = 2.minutes.ago
        last_course_in_results = create(:course, course_code: "LAST2", age: timestamp_of_last_course, provider: provider)

        get '/api/v1/courses',
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: { changed_since: 30.minutes.ago.utc.iso8601 }

        expect(response.headers).to have_key "Link"
        expected = /#{request.base_url + request.path}\?changed_since=#{(timestamp_of_last_course + 1.second).utc.iso8601}&from_course_id=#{last_course_in_results.id}&per_page=100; rel="next"$/
        expect(response.headers["Link"]).to match expected
      end

      it 'includes correct next link when there is an empty set' do
        provided_timestamp = 5.seconds.ago.utc.iso8601

        get '/api/v1/courses',
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: { changed_since: provided_timestamp }

        expected = /#{request.base_url + request.path}\?changed_since=#{provided_timestamp}&from_course_id=&per_page=100; rel="next"$/
        expect(response.headers["Link"]).to match expected
      end

      context "with many courses" do
        before do
          11.times do |i|
            create(:course, course_code: "CRSE#{i + 1}", age: (20 - i).minutes.ago, provider: provider)
          end
        end

        it 'pages properly' do
          get '/api/v1/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: 21.minutes.ago.utc.iso8601, per_page: 10 }

          returned_course_codes = get_course_codes_from_body(response.body)

          expected_course_codes = (1..10).map { |n| "CRSE#{n}" }
          expect(returned_course_codes).to match_array expected_course_codes

          next_url = response.headers["Link"]

          get next_url,
            headers: { 'HTTP_AUTHORIZATION' => credentials }

          returned_course_codes = get_course_codes_from_body(response.body)

          expect(returned_course_codes.size).to eq 1
          expect(returned_course_codes).to include "CRSE11"

          next_url = response.headers["Link"]

          get next_url,
            headers: { 'HTTP_AUTHORIZATION' => credentials }

          returned_course_codes = get_course_codes_from_body(response.body)

          expect(returned_course_codes.size).to eq 0
        end
      end

      context "with courses with the same timestamp" do
        before do
          3.times do |i|
            create(:course, course_code: "CRSE#{i + 1}", age: 2.minutes.ago, provider: provider)
          end
        end

        it 'pages properly' do
          get '/api/v1/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: 3.minutes.ago.utc.iso8601, per_page: 1 }

          returned_course_codes = get_course_codes_from_body(response.body)

          3.times do |i|
            expect(returned_course_codes).to include "CRSE#{i + 1}"

            get response.headers["Link"], headers: { 'HTTP_AUTHORIZATION' => credentials }

            returned_course_codes = get_course_codes_from_body(response.body)
          end

          expect(returned_course_codes.size).to eq 0
        end
      end
    end
  end
end

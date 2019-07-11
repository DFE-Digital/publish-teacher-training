require "rails_helper"

def get_course_codes_from_body(body)
  json = JSON.parse(body)
  json.map { |course| course["course_code"] }
end

describe "Courses API", type: :request do
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
                        provider_type: :scitt,
                        scheme_member: 'Y',
                        enrichments: [])
    end


    context "without changed_since parameter" do
      before do
        site = FactoryBot.create(:site, code: "-", location_name: "Main Site", provider: provider)
        subject1 = FactoryBot.find_or_create(:subject, :secondary)
        subject2 = FactoryBot.find_or_create(:subject, :mathematics)

        course = FactoryBot.create(:course,
                                   course_code: "2HPF",
                                   start_date: Date.new(2019, 9, 1),
                                   name: "Religious Education",
                                   subjects: [subject1, subject2],
                                   study_mode: :full_time,
                                   age_range: 'primary',
                                   english: :equivalence_test,
                                   maths: :not_required,
                                   profpost_flag: :postgraduate,
                                   program_type: :school_direct_training_programme,
                                   modular: "",
                                   provider: provider,
                                   age: 2.hours.ago)

        FactoryBot.create(:site_status,
                          vac_status: :full_time_vacancies,
                          publish: 'Y',
                          status: :running,
                          applications_accepted_from: "2018-10-09 00:00:00",
                          course: course,
                          site: site)

        course.update changed_at: 2.hours.ago
      end

      it "returns http success" do
        get '/api/v1/2019/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials }
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
                                "recruitment_cycle" => "2019",
                                "campus_statuses" => [
                                  {
                                    "campus_code" => "-",
                                    "name" => "Main Site",
                                    "vac_status" => "F",
                                    "publish" => "Y",
                                    "status" => "R",
                                    "course_open_date" => "2018-10-09",
                                  }
                                ],
                                "subjects" => [
                                  {
                                    "subject_code" => "05",
                                    "subject_name" => "Secondary"
                                  },
                                  {
                                    "subject_code" => "G1",
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

      it 'includes correct next link in response headers' do
        create(:course,
               course_code: "LAST1",
               age: 10.minutes.ago,
               provider: provider)

        timestamp_of_last_course = 2.minutes.ago
        _last_course_in_results = create(:course,
                                         course_code: "LAST2",
                                         age: timestamp_of_last_course,
                                         provider: provider)

        get '/api/v1/2019/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials }

        expect(response.headers).to have_key "Link"
        url = url_for(
          recruitment_year: 2019,
          params: {
            changed_since: timestamp_of_last_course.utc.strftime('%FT%T.%6NZ'),
            per_page: 100
          }
        )

        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end
    end


    context 'with multiple recruitment cycles' do
      describe 'JSON body response' do
        let(:provider) { build(:provider, recruitment_cycle: current_cycle) }
        let(:current_cycle) { build(:recruitment_cycle, year: '2019') }
        let(:course) { create(:course, provider: provider) }
        let(:provider2) { build(:provider, recruitment_cycle: next_cycle) }
        let(:next_cycle) { build(:recruitment_cycle, year: '2020') }
        let(:course2) { create(:course, provider: provider2) }

        before do
          course
          course2
          get_index
        end

        context 'with no cycle specified in the route' do
          let(:get_index) { get '/api/v1/courses', headers: { 'HTTP_AUTHORIZATION' => credentials } }

          it 'defaults to the current cycle when year' do
            returned_course_codes = get_course_codes_from_body(response.body)

            expect(returned_course_codes).not_to include course2.course_code
            expect(returned_course_codes).to include course.course_code
          end
        end
        context 'with a future recruitment cycle specified in the route' do
          let(:get_index) { get '/api/v1/2020/courses', headers: { 'HTTP_AUTHORIZATION' => credentials } }

          it 'only returns courses from the requested cycle' do
            returned_course_codes = get_course_codes_from_body(response.body)

            expect(returned_course_codes).to include course2.course_code
            expect(returned_course_codes).not_to include course.course_code
          end
        end
      end
    end


    context "with changed_since parameter" do
      describe "JSON body response" do
        it 'contains expected courses' do
          old_course = create(:course, course_code: "SINCE1", age: 1.hour.ago)
          updated_course = create(:course, course_code: "SINCE2", age: 5.minutes.ago)

          get '/api/v1/2019/courses',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 10.minutes.ago.utc.iso8601 }

          returned_course_codes = get_course_codes_from_body(response.body)

          expect(returned_course_codes).not_to include old_course.course_code
          expect(returned_course_codes).to include updated_course.course_code
        end
      end

      context 'with recruitment year specified in params' do
        it 'includes the correct next link in the header' do
          create(:course,
                 course_code: "LAST1",
                 age: 10.minutes.ago,
                 provider: provider)

          timestamp_of_last_course = 2.minutes.ago
          _last_course_in_results = create(:course,
                                           course_code: "LAST2",
                                           age: timestamp_of_last_course,
                                           provider: provider)

          get '/api/v1/courses?recruitment_year=2019',
              headers: { 'HTTP_AUTHORIZATION' => credentials },
              params: { changed_since: 30.minutes.ago.utc.iso8601 }


          expect(response.headers).to have_key "Link"
          url = url_for(
            recruitment_year: 2019,
            params: {
              changed_since: timestamp_of_last_course.utc.strftime('%FT%T.%6NZ'),
              per_page: 100,
            })
          expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
        end
      end

      it 'includes correct next link in response headers' do
        create(:course,
               course_code: "LAST1",
               age: 10.minutes.ago,
               provider: provider)

        timestamp_of_last_course = 2.minutes.ago
        _last_course_in_results = create(:course,
                                         course_code: "LAST2",
                                         age: timestamp_of_last_course,
                                         provider: provider)

        get '/api/v1/2019/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: 30.minutes.ago.utc.iso8601 }


        expect(response.headers).to have_key "Link"
        url = url_for(
          recruitment_year: 2019,
          params: {
            changed_since: timestamp_of_last_course.utc.strftime('%FT%T.%6NZ'),
            per_page: 100
          }
)
        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end

      it 'includes correct next link when there is an empty set' do
        provided_timestamp = 5.seconds.ago.utc.iso8601

        get '/api/v1/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: provided_timestamp }

        url = url_for(recruitment_year: 2019, params: {
                        changed_since: provided_timestamp,
                        per_page: 100
                      })
        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end

      it 'includes correct next link when there is an empty set' do
        provided_timestamp = 5.seconds.ago.utc.iso8601

        get '/api/v1/2020/courses',
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: { changed_since: provided_timestamp }

        url = url_for(recruitment_year: 2020, params: {
                        changed_since: provided_timestamp,
                        per_page: 100
                      })
        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end

      def get_next_courses(link, params = {})
        get link,
            headers: { 'HTTP_AUTHORIZATION' => credentials },
            params: params
      end

      context "with many courses" do
        before do
          @courses = Array.new(25) do |i|
            create(:course, course_code: "CRSE#{i + 1}",
                 changed_at: (30 - i).minutes.ago,
                 provider: provider)
          end
        end

        it 'pages properly' do
          get_next_courses '/api/v1/courses', per_page: 10

          expect(response.body)
            .to have_courses(@courses[0..9])

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body)
            .to have_courses(@courses[10..19])

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body)
            .to have_courses(@courses[20..24])

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body).to_not have_courses

          random_course = Course.all.sample
          random_course.touch

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body)
            .to have_courses([random_course])
        end
      end

      context "with many courses updated in the same second" do
        let!(:next_cycle) { create(:recruitment_cycle, year: '2020') }
        timestamp = 1.second.ago
        before do
          @courses = Array.new(25) do |i|
            create(:course, course_code: "CRSE#{i + 1}",
                 changed_at: timestamp + i / 1000.0,
                 provider: provider)
          end
        end


        it 'pages properly' do
          get_next_courses '/api/v1/courses', per_page: 10, recruitment_year: 2019
          expect(response.body)
            .to have_courses(@courses[0..9])

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body)
            .to have_courses(@courses[10..19])

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body)
            .to have_courses(@courses[20..24])

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body).to_not have_courses

          random_course = Course.all.sample
          random_course.touch

          get_next_courses response.headers['Link'].split(';').first
          expect(response.body)
            .to have_courses([random_course])
        end

        it 'pages properly with specified recruitment year' do
          get_next_courses '/api/v1/2020/courses', per_page: 10
          expect(response.body).to eq '[]'
        end
      end
    end

    describe "site status" do
      context "when there are no vacancies" do
        before do
          create(:site_status, :running, :with_no_vacancies)
        end

        it 'presents the site status as suspended (so that the UTT Apply system hides the site altogether)' do
          get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => credentials }

          json = JSON.parse(response.body)

          expect(json[0]["campus_statuses"][0]["status"]). to eq(SiteStatus.statuses["suspended"])
        end
      end
    end
  end
end

require "rails_helper"

def get_course_codes_from_body(body)
  json = JSON.parse(body)
  json.map { |course| course["course_code"] }
end

describe "Courses API", type: :request do
  describe "GET index" do
    let(:credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials("bats")
    end
    let(:unauthorized_credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials("foo")
    end

    let(:provider) do
      create(:provider,
             provider_name: "ACME SCITT",
             provider_code: "2LD",
             provider_type: :scitt,
             scheme_member: "Y")
    end
    let(:current_cycle) { find_or_create :recruitment_cycle }
    let(:current_year)  { current_cycle.year.to_i }
    let(:previous_year) { current_year - 1 }
    let(:next_year)     { current_year + 1 }


    context "without changed_since parameter" do
      let(:age_range_in_years) { "3_to_7" }

      before do
        Timecop.freeze(2.hours.ago) do
          site = create(:site, code: "-", location_name: "Main Site", provider: provider)
          subject1 = find_or_create(:secondary_subject, :modern_languages)
          subject2 = find_or_create(:modern_languages_subject, :german)

          course = create(:course,
                          level: "secondary",
                          course_code: "2HPF",
                          start_date: Date.new(current_year, 9, 1),
                          name: "Religious Education",
                          subjects: [subject1, subject2],
                          study_mode: :full_time,
                          age_range_in_years: age_range_in_years,
                          english: :equivalence_test,
                          maths: :equivalence_test,
                          science: :equivalence_test,
                          profpost_flag: :postgraduate,
                          program_type: :scitt_programme,
                          applications_open_from: "#{previous_year}-10-09 00:00:00",
                          modular: "",
                          provider: provider)

          create(:site_status,
                 vac_status: :full_time_vacancies,
                 publish: "Y",
                 status: :running,
                 course: course,
                 site: site)
        end
      end

      it "returns http success" do
        get "/api/v1/#{current_year}/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials }
        expect(response).to have_http_status(:success)
      end

      it "returns http unauthorised" do
        get "/api/v1/#{current_year}/courses",
            headers: { "HTTP_AUTHORIZATION" => unauthorized_credentials }
        expect(response).to have_http_status(:unauthorized)
      end

      it "JSON body response contains expected course attributes" do
        get "/api/v1/#{current_year}/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials }

        json = JSON.parse(response.body)
        expect(json). to eq([
                              {
                                "course_code" => "2HPF",
                                "start_month" => "#{current_year}-09-01T00:00:00Z",
                                "start_month_string" => "September",
                                "name" => "Religious Education",
                                "study_mode" => "F",
                                "copy_form_required" => "Y",
                                "profpost_flag" => "PG",
                                "program_type" => "SC",
                                "age_range" => "S",
                                "modular" => "",
                                "english" => 3,
                                "maths" => 3,
                                "science" => 3,
                                "recruitment_cycle" => current_year.to_s,
                                "campus_statuses" => [
                                  {
                                    "campus_code" => "-",
                                    "name" => "Main Site",
                                    "vac_status" => "F",
                                    "publish" => "Y",
                                    "status" => "R",
                                    "course_open_date" => "#{previous_year}-10-09",
                                  },
                                ],
                                "subjects" => [
                                  {
                                    "subject_code" => "17",
                                    "subject_name" => "German",
                                    "type" => "ModernLanguagesSubject",
                                  },
                                ],
                                "provider" => {
                                  "institution_code" => "2LD",
                                  "institution_name" => "ACME SCITT",
                                  "institution_type" => "B",
                                  "accrediting_provider" => "Y",
                                  "scheme_member" => "Y",
                                },
                                "accrediting_provider" => nil,
                                "created_at" => provider.courses.first.created_at.iso8601,
                                "changed_at" => provider.courses.first.changed_at.iso8601,
                              },
                            ])
      end

      it "includes correct next link in response headers" do
        timestamp_of_first_course = 10.minutes.ago
        Timecop.freeze(timestamp_of_first_course) do
          first_course = create(:course,
                                :infer_level,
                                course_code: "LAST1",
                                provider: provider)

          create(:site_status, :published, course: first_course)
        end

        timestamp_of_last_course = 2.minutes.ago

        Timecop.freeze(timestamp_of_last_course) do
          last_course_in_results = create(:course,
                                          :infer_level,
                                          course_code: "LAST2",
                                          provider: provider)
          create(:site_status, :published, course: last_course_in_results)
        end

        get "/api/v1/#{current_year}/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials }

        expect(response.headers).to have_key "Link"
        url = url_for(
          recruitment_year: current_year,
          params: {
            changed_since: timestamp_of_last_course.utc.strftime("%FT%T.%6NZ"),
            per_page: 100,
          },
        )

        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end
    end

    describe "JSON body response" do
      let(:provider) { build(:provider) }
      let(:course) { create(:course, provider: provider, site_statuses: [create(:site_status, :published)]) }
      let(:provider2) { build(:provider, recruitment_cycle: next_cycle) }
      let(:course2) { create(:course, provider: provider2, site_statuses: [create(:site_status, :published)]) }
      let(:next_cycle) { build(:recruitment_cycle, :next) }

      before do
        course
        course2
      end

      context "with no cycle specified in the route" do
        it "defaults to the current cycle when year" do
          get "/api/v1/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }

          returned_course_codes = get_course_codes_from_body(response.body)

          expect(returned_course_codes).not_to include course2.course_code
          expect(returned_course_codes).to include course.course_code
        end
      end
      context "with a future recruitment cycle specified in the route" do
        it "only returns courses from the requested cycle" do
          get "/api/v1/#{next_year}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }

          returned_course_codes = get_course_codes_from_body(response.body)

          expect(returned_course_codes).to include course2.course_code
          expect(returned_course_codes).not_to include course.course_code
        end
      end

      context "with a past recruitment cycle specified in the route" do
        it "returns not found" do
          expect {
            get "/api/v1/#{previous_year}/courses",
                headers: { "HTTP_AUTHORIZATION" => credentials }
          }.to raise_error(ActionController::RoutingError)
        end
      end
    end

    context "with changed_since parameter" do
      describe "JSON body response" do
        it "contains expected courses" do
          site_status1 = create(:site_status, :published)
          site_status2 = create(:site_status, :published)
          old_course = create(:course, course_code: "SINCE", site_statuses: [site_status1])

          Timecop.freeze(5.minutes.from_now) do
            new_course = create(:course, course_code: "SINCE2", site_statuses: [site_status2])

            get "/api/v1/#{current_year}/courses?changed_since=#{3.minutes.ago.utc.iso8601}",
                headers: { "HTTP_AUTHORIZATION" => credentials }

            returned_course_codes = get_course_codes_from_body(response.body)

            expect(returned_course_codes).not_to include old_course.course_code
            expect(returned_course_codes).to include new_course.course_code
          end
        end
      end

      describe "response headers" do
        context "when the recruitment year is in the path" do
          it "includes the correct next link" do
            course_time = 10.minutes.ago
            first_course = create(:course,
                                  course_code: "LAST1",
                                  age: course_time,
                                  provider: provider)

            Timecop.freeze(course_time) do
              create(:site_status, :published, course: first_course)
            end

            timestamp_of_last_course = 2.minutes.ago
            Timecop.freeze(timestamp_of_last_course) do
              last_course_in_results = create(:course,
                                              course_code: "LAST2",
                                              age: timestamp_of_last_course,
                                              provider: provider)
              create(:site_status, :published, course: last_course_in_results)
            end

            get "/api/v1/#{current_year}/courses",
                headers: { "HTTP_AUTHORIZATION" => credentials },
                params: { changed_since: 30.minutes.ago.utc.iso8601 }


            expect(response.headers).to have_key "Link"
            url = url_for(
              recruitment_year: current_year,
              params: {
                changed_since: timestamp_of_last_course.utc.strftime("%FT%T.%6NZ"),
                per_page: 100,
              },
            )
            expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
          end
        end

        context "when the recruitment year is in the params" do
          # We want to keep legacy support for year as a param in order to
           # maintain backwards compatibility. This will avoid breaking calls
           # from UCAS should they use this older style. The next links we
           # generate used to were of this style, and the UCAS systems
           # were making requests in this style.
          it "includes the correct next link" do
            course_time = 10.minutes.ago
            first_course = create(:course,
                                  course_code: "LAST1",
                                  age: course_time,
                                  provider: provider)

            Timecop.freeze(course_time) do
              create(:site_status, :published, course: first_course)
            end

            timestamp_of_last_course = 2.minutes.ago
            Timecop.freeze(timestamp_of_last_course) do
              last_course_in_results = create(:course,
                                              course_code: "LAST2",
                                              age: timestamp_of_last_course,
                                              provider: provider)
              create(:site_status, :published, course: last_course_in_results)
            end
            get "/api/v1/courses?recruitment_year=#{next_year}",
                headers: { "HTTP_AUTHORIZATION" => credentials },
                params: { changed_since: 30.minutes.ago.utc.iso8601 }


            expect(response.headers).to have_key "Link"
            url = url_for(
              recruitment_year: next_year,
              params: {
                changed_since: timestamp_of_last_course.utc.strftime("%FT%T.%6NZ"),
                per_page: 100,
              },
            )
            expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
          end

          it "returns bad_request for previous year" do
            get "/api/v1/courses?recruitment_year=#{previous_year}",
                headers: { "HTTP_AUTHORIZATION" => credentials },
                params: { changed_since: 30.minutes.ago.utc.iso8601 }

            expect(response).to have_http_status(:bad_request)
          end
        end
      end


      it "includes correct next link when there is an empty set" do
        provided_timestamp = 5.seconds.ago.utc.iso8601

        get "/api/v1/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials },
            params: { changed_since: provided_timestamp }

        url = url_for(recruitment_year: current_year, params: {
                        changed_since: provided_timestamp,
                        per_page: 100,
                      })
        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end

      it "includes correct next link when there is an empty set" do
        provided_timestamp = 5.seconds.ago.utc.iso8601


        get "/api/v1/#{next_year}/courses",
            headers: { "HTTP_AUTHORIZATION" => credentials },
            params: { changed_since: provided_timestamp }

        url = url_for(recruitment_year: next_year, params: {
                        changed_since: provided_timestamp,
                        per_page: 100,
                      })
        expect(response.headers["Link"]).to match "#{url}; rel=\"next\""
      end

      def get_next_courses(link, params = {})
        get link,
            headers: { "HTTP_AUTHORIZATION" => credentials },
            params: params
      end

      context "with many courses" do
        before do
          @courses = Array.new(25) do |i|
            create(:course, course_code: "CRSE#{i + 1}",
                 changed_at: (30 - i).minutes.ago,
                 provider: provider,
                 site_statuses: [create(:site_status, :published)])
          end
        end

        it "pages properly" do
          get_next_courses "/api/v1/courses", per_page: 10

          expect(response.body)
            .to have_courses(@courses[0..9])

          get_next_courses response.headers["Link"].split(";").first
          expect(response.body)
            .to have_courses(@courses[10..19])

          get_next_courses response.headers["Link"].split(";").first
          expect(response.body)
            .to have_courses(@courses[20..24])

          get_next_courses response.headers["Link"].split(";").first
          expect(response.body).to_not have_courses
        end
      end

      context "with many courses updated in the same second" do
        let!(:next_cycle) { create(:recruitment_cycle, year: next_year) }
        timestamp = 1.second.ago
        before do
          @courses = Array.new(25) do |i|
            create(:course, course_code: "CRSE#{i + 1}",
                 changed_at: timestamp + i / 1000.0,
                 provider: provider,
                 site_statuses: [create(:site_status, :published)])
          end
        end


        it "pages properly" do
          get_next_courses "/api/v1/courses",
                           per_page: 10,
                           recruitment_year: current_year
          expect(response.body)
            .to have_courses(@courses[0..9])

          get_next_courses response.headers["Link"].split(";").first
          expect(response.body)
            .to have_courses(@courses[10..19])

          get_next_courses response.headers["Link"].split(";").first
          expect(response.body)
            .to have_courses(@courses[20..24])

          get_next_courses response.headers["Link"].split(";").first
          expect(response.body).to_not have_courses
        end

        it "pages properly with specified recruitment year" do
          get_next_courses "/api/v1/#{next_year}/courses", per_page: 10
          expect(response.body).to eq "[]"
        end
      end
    end

    describe "site status" do
      context "when there are no vacancies" do
        before do
          create(:site_status, :running, :with_no_vacancies)
        end

        it "presents the site status as suspended (so that the UTT Apply system hides the site altogether)" do
          get "/api/v1/#{current_year}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }

          json = JSON.parse(response.body)

          expect(json[0]["campus_statuses"][0]["status"]). to eq(SiteStatus.statuses["suspended"])
        end
      end
    end

    context "with new courses" do
      let(:current_cycle) { RecruitmentCycle.current_recruitment_cycle }
      let(:provider1) { create(:provider, recruitment_cycle: current_cycle) }
      let(:provider2) { create(:provider, recruitment_cycle: current_cycle) }

      let(:course1) { create(:course, study_mode: "full_time", profpost_flag: "postgraduate", program_type: "higher_education_programme", provider: provider1) }
      let(:course2) { create(:course, study_mode: "full_time", profpost_flag: "postgraduate", program_type: "higher_education_programme", provider: provider1) }

      let!(:status1) { create(:site_status, status: :new_status, course: course1, vac_status: "full_time_vacancies") }
      let!(:status2) { create(:site_status, status: :new_status, course: course2, vac_status: "full_time_vacancies") }
      let!(:status3) { create(:site_status, status: :running, course: course2, vac_status: "full_time_vacancies") }

      it "does not send courses marked new" do
        get "/api/v1/#{current_year}/courses", headers: { "HTTP_AUTHORIZATION" => credentials }

        data = JSON.parse(response.body)
        expect(data.length).to eq(1)
        expect(data.first["course_code"]).to eq(course2.course_code)
        expect(data.first["campus_statuses"].length).to eq(1)
        expect(data.first["campus_statuses"].first["campus_code"]).to eq(status3.site.code)
      end
    end

    context "with a SEND course" do
      let(:course) { create(:course, is_send: true, subjects: [find_or_create(:primary_subject, :primary)]) }
      let(:site) { create(:site_status, :published, course: course) }

      before do
        course
        site

        get "/api/v1/courses", headers: { "HTTP_AUTHORIZATION" => credentials }
      end

      it "contains a SEND subject" do
        json = JSON.parse(response.body).first

        expect(json).to_not have_key("is_send") # API v2

        expect(json["subjects"].length).to eq(2)
        expect(json["subjects"]).to include(
          "subject_code" => "U3",
          "subject_name" => "Special Educational Needs",
          "type" => nil,
        )
      end

      it "does not create a SEND subject" do
        expect(Subject.where(subject_code: "U3").count).to eq(0)
      end
    end

    describe "age_range" do
      context "when level is 'primary'" do
        let(:course) { create(:course, :primary) }
        let(:site) { create(:site_status, :published, course: course) }

        before do
          course
          site

          get "/api/v1/#{current_year}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }
        end

        it "should equal 'P'" do
          json = JSON.parse(response.body).first
          expect(json["age_range"]).to eq("P")
        end
      end

      context "when age_range_in_years is '7_to_14'" do
        let(:course) { create(:course, :primary, age_range_in_years: "7_to_14") }
        let(:site) { create(:site_status, :published, course: course) }

        before do
          course
          site

          get "/api/v1/#{current_year}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }
        end

        it "should equal 'M'" do
          json = JSON.parse(response.body).first
          expect(json["age_range"]).to eq("M")
        end
      end

      context "default" do
        let(:course) { create(:course, :secondary) }
        let(:site) { create(:site_status, :published, course: course) }

        before do
          course
          site

          get "/api/v1/#{current_year}/courses",
              headers: { "HTTP_AUTHORIZATION" => credentials }
        end

        it "should equal 'S'" do
          json = JSON.parse(response.body).first
          expect(json["age_range"]).to eq("S")
        end
      end
    end
  end
end

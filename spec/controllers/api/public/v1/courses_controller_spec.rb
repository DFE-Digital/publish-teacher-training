require "rails_helper"

RSpec.describe API::Public::V1::CoursesController do
  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }

  describe "#index" do
    context "when there are no courses" do
      before do
        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year,
        }
      end

      it "returns empty array of data" do
        expect(json_response["data"]).to eql([])
      end
    end

    context "when there are courses" do
      before do
        provider.courses << build_list(:course, 2, provider:)
      end

      context "with no recruitment cycle provided" do
        let(:next_cycle) { create :recruitment_cycle, :next }

        before do
          next_cycle

          get :index, params: {
            include: "recruitment_cycle",
          }
        end

        it "returns courses for the current cycle" do
          parsed_recruitment_cycle_id = json_response["data"][0].dig("relationships", "recruitment_cycle", "data", "id").to_i
          expect(parsed_recruitment_cycle_id).to eq(recruitment_cycle.id)
          expect(json_response["data"].size).to be(2)
        end
      end

      context "default response" do
        before do
          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
          }
        end

        it "returns correct number of courses" do
          expect(json_response["data"].size).to be(2)
        end
      end

      context "with pagination" do
        before do
          provider.courses << build_list(:course, 5, provider:)

          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            **pagination,
          }
        end

        let(:pagination) do
          {
            page:,
            per_page: 3,
          }
        end

        context "when requested page is valid" do
          let(:first_page) { 1 }
          let(:last_page) { 3 }

          let(:url_prefix) do
            "http://test.host/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/courses?page="
          end

          context "page 1" do
            let(:page) { first_page }

            it "returns links" do
              links = json_response["links"]

              expect(links["first"]).to eq "#{url_prefix}#{first_page}&per_page=3"
              expect(links["last"]).to eq "#{url_prefix}#{last_page}&per_page=3"
              expect(links["prev"]).to be_nil
              expect(links["next"]).to eq "#{url_prefix}#{page + 1}&per_page=3"
            end
          end

          context "page 2" do
            let(:page) { 2 }

            it "returns links" do
              links = json_response["links"]

              expect(links["first"]).to eq "#{url_prefix}#{first_page}&per_page=3"
              expect(links["last"]).to eq "#{url_prefix}#{last_page}&per_page=3"
              expect(links["prev"]).to eq "#{url_prefix}#{page - 1}&per_page=3"
              expect(links["next"]).to eq "#{url_prefix}#{page + 1}&per_page=3"
            end
          end

          context "page 3" do
            let(:page) { last_page }

            it "returns links" do
              links = json_response["links"]

              expect(links["first"]).to eq "#{url_prefix}#{first_page}&per_page=3"
              expect(links["last"]).to eq "#{url_prefix}#{last_page}&per_page=3"
              expect(links["prev"]).to eq "#{url_prefix}#{page - 1}&per_page=3"
              expect(links["next"]).to be_nil
            end
          end
        end

        describe "overflow" do
          context "page 4" do
            let(:page) { 4 }

            it "returns no links" do
              links = json_response["links"]

              expect(links).to be_nil
            end

            it "returns a bad request response" do
              expect(response).to have_http_status(:bad_request)
            end

            it "returns a friendly error message" do
              expect(json_response["errors"][0]["detail"]).to eql(I18n.t("pagy.overflow"))
            end
          end
        end
      end

      context "with includes" do
        before do
          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            include: "recruitment_cycle,provider",
          }
        end

        it "returns the requested associated data in the response" do
          relationships = json_response["data"][0]["relationships"]

          recruitment_cycle_id = relationships.dig("recruitment_cycle", "data", "id").to_i
          provider_id = relationships.dig("provider", "data", "id").to_i

          expect(json_response["data"][0]["relationships"].keys.sort).to eq(
            %w[accredited_body provider recruitment_cycle],
          )

          expect(recruitment_cycle_id).to eq(provider.recruitment_cycle.id)
          expect(provider_id).to eq(provider.id)
        end
      end

      context "with sorting" do
        let(:sort_attribute) { "name,provider.provider_name" }

        before do
          allow(CourseSearchService).to receive(:call).and_return(Course.all)

          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            sort: sort_attribute,
          }
        end

        it "delegates to the CourseSearchService" do
          expect(CourseSearchService).to have_received(:call).with(
            hash_including(sort: sort_attribute),
          )
        end
      end

      context "with filtering" do
        context "with valid funding type" do
          before do
            provider.courses << build(:course, provider:)

            allow(CourseSearchService).to receive(:call).and_return(Course.all)

            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year,
              filter: {
                funding_type: "salary",
              },
            }
          end

          it "delegates to the CourseSearchService" do
            expect(CourseSearchService).to have_received(:call).with(
              hash_including(filter: ActionController::Parameters.new(funding_type: "salary")),
            )
          end
        end

        context "when updated_since is invalid" do
          before do
            provider.courses << build(:course, provider:)

            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year,
              filter: {
                updated_since: "foobar",
              },
            }
          end

          it "returns a 400 error message" do
            expect(response).to have_http_status(:bad_request)
            expect(json_response["message"]).to eq("Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`")
          end
        end
      end

      context "courses count" do
        it "returns the course count in a meta object" do
          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
          }

          json_response = JSON.parse(response.body)
          meta = json_response["meta"]

          expect(meta["count"]).to be(2)
        end

        context "default fields" do
          let(:fields) do
            %w[ accredited_body_code
                age_maximum
                age_minimum
                bursary_amount
                bursary_requirements
                created_at
                funding_type
                gcse_subjects_required
                level
                name
                program_type
                qualifications
                scholarship_amount
                study_mode
                uuid
                degree_grade
                degree_subject_requirements
                accept_pending_gcse
                accept_gcse_equivalency
                accept_english_gcse_equivalency
                accept_maths_gcse_equivalency
                accept_science_gcse_equivalency
                additional_gcse_equivalencies
                about_accredited_body
                applications_open_from
                changed_at
                code
                findable
                has_early_career_payments
                has_scholarship
                has_vacancies
                is_send
                last_published_at
                open_for_applications
                required_qualifications_english
                required_qualifications_maths
                required_qualifications_science
                running
                start_date
                state
                summary
                subject_codes
                required_qualifications
                about_course
                course_length
                fee_details
                fee_international
                fee_domestic
                financial_support
                how_school_placements_work
                interview_process
                other_requirements
                personal_qualities
                salary_details
                can_sponsor_skilled_worker_visa
                can_sponsor_student_visa]
          end

          before do
            get :index, params: {
              recruitment_cycle_year: recruitment_cycle.year,
            }
          end

          it "returns the default fields" do
            expect(json_response["data"].first["attributes"].keys).to match_array(fields)
          end
        end
      end
    end
  end
end

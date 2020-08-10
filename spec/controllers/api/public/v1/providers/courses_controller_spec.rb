require "rails_helper"

RSpec.describe API::Public::V1::Providers::CoursesController do
  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }

  describe "#index" do
    context "when there are no courses" do
      it "returns empty array of data" do
        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
        }
        expect(JSON.parse(response.body)["data"]).to eql([])
      end
    end

    context "when there are courses" do
      before do
        create(:course, provider: provider)
        create(:course, provider: provider)
      end

      it "returns correct number of courses" do
        get :index, params: { recruitment_cycle_year: "2020", provider_code: provider.provider_code }
        expect(JSON.parse(response.body)["data"].size).to eql(2)
      end
    end

    describe "pagination" do
      let(:courses) do
        array = []

        7.times { |n| array << build(:course, id: n + 1) }

        array
      end

      before do
        allow(controller).to receive(:courses).and_return(courses)
      end

      it "can pagingate to page 2" do
        get :index, params: {
          recruitment_cycle_year: "2020",
          provider_code: "ABC",
          page: {
            page: 2,
            per_page: 5,
          },
        }

        expect(JSON.parse(response.body)["data"].size).to eql(2)
      end
    end

    describe "sort" do
      before do
        create(:course, provider: provider, name: "french")
        create(:course, provider: provider, name: "spanish")
        create(:course, provider: provider, name: "computing")
      end

      it "returns courses in default name order" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
        }

        expected_names = %w[computing french spanish]
        actual_names = JSON.parse(response.body)["data"].map { |datum| datum["attributes"]["name"] }
        expect(actual_names).to eql(expected_names)
      end

      it "returns courses in name order" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          sort: "name",
        }

        expected_names = %w[computing french spanish]
        actual_names = JSON.parse(response.body)["data"].map { |datum| datum["attributes"]["name"] }
        expect(actual_names).to eql(expected_names)
      end

      it "returns courses in reverse name order" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          sort: "-name",
        }

        expected_names = %w[spanish french computing]
        actual_names = JSON.parse(response.body)["data"].map { |datum| datum["attributes"]["name"] }
        expect(actual_names).to eql(expected_names)
      end

      it "ignores unpermitted sorts" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          sort: "foo",
        }

        expected_names = %w[computing french spanish]
        actual_names = JSON.parse(response.body)["data"].map { |datum| datum["attributes"]["name"] }
        expect(actual_names).to eql(expected_names)
      end
    end

    describe "field" do
      let!(:attributes) { API::Public::V1::SerializableCourse.new(object: course).as_jsonapi[:attributes] }
      let!(:course) { create(:course, provider: provider, name: "german") }

      it "returns all fields when none are specified" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
        }

        expect(JSON.parse(response.body)["data"][0]["attributes"].count).to eql(attributes.size)
      end

      it "returns course name as the only field" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          fields: { courses: "name,code" },
        }

        expect(JSON.parse(response.body)["data"][0]["attributes"].keys).to eql(%w[name code])
      end
    end

    describe "include" do
      before do
        create(:course, provider: provider)
      end

      it "returns the provider connected to the course" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          include: "provider",
        }

        expect(JSON.parse(response.body)["data"][0]["relationships"].keys).to eql(%w[provider])
        expect(JSON.parse(response.body)["included"][0]["id"]).to eql(provider.id.to_s)
        expect(JSON.parse(response.body)["included"][0]["type"]).to eql("providers")
      end

      it "doesn't include subjects as they aren't permitted" do
        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          include: "subjects",
        }

        expect(JSON.parse(response.body)["data"][0]["relationships"]).to eql("provider" => { "meta" => { "included" => false } })
      end
    end

    describe "filtering" do
      context "when has_vacancies is true" do
        before do
          course1 = create(:course, provider: provider)
          course2 = create(:course, provider: provider)

          create(:site_status, :with_any_vacancy, course: course1)
          create(:site_status, :with_no_vacancies, course: course2)
        end

        it "returns courses that only have vacancies" do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            filter: {
              has_vacancies: true,
            },
          }

          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end
      end

      context "funding given" do
        before do
          create(:course, :with_salary, provider: provider)
          create(:course, :with_apprenticeship, provider: provider)
          create(:course, :fee_type_based, provider: provider)
        end

        it "returns courses with specified funding" do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            filter: {
              funding: "salary,fee",
            },
          }

          expect(JSON.parse(response.body)["data"].size).to eql(2)
        end
      end

      context "qualification given" do
        before do
          create(:course, :resulting_in_qts, provider: provider)
          create(:course, :resulting_in_pgce_with_qts, provider: provider)
          create(:course, :resulting_in_pgde, provider: provider)
        end

        it "returns courses with specified qualifications" do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            filter: {
              qualification: "qts,pgce_with_qts",
            },
          }

          expect(JSON.parse(response.body)["data"].size).to eql(2)
        end
      end

      context "study_type given" do
        before do
          create(:course, :full_time_or_part_time, provider: provider)
          create(:course, :full_time, provider: provider)
          create(:course, :part_time, provider: provider)
        end

        it "returns courses with specified study type" do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            filter: {
              study_type: "full_time",
            },
          }

          expect(JSON.parse(response.body)["data"].size).to eql(2)
        end
      end

      context "subjects given" do
        before do
          create(:course, :primary, provider: provider)
          create(:course, :secondary, provider: provider)
          create(:course, :further_education, provider: provider)
        end

        it "returns courses with specified subjects" do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            filter: {
              subjects: "00,F0",
            },
          }

          expect(JSON.parse(response.body)["data"].size).to eql(2)
        end
      end

      context "send_courses given" do
        before do
          create(:course, provider: provider)
          create(:course, :send, provider: provider)
        end

        it "returns courses with send specialism" do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            filter: {
              send_courses: true,
            },
          }

          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end
      end
    end
  end

  describe "#show" do
    context "when course exists" do
      let!(:course) { create(:course, provider: provider) }

      it "returns the course" do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code
        }

        expect(response).to be_successful
        expect(JSON.parse(response.body)["data"]["id"]).to eql(course.id.to_s)
      end
    end

    context "when course does not exist" do
      it "returns 404" do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: "ABCD"
        }

        expect(response.status).to eql(404)
      end
    end

    context "when provider does not exist" do
      it "returns 404" do
        get :show, params: {
          recruitment_cycle_year: "2020",
          provider_code: "ABC",
          code: "ABCD"
        }

        expect(response.status).to eql(404)
      end
    end
  end
end

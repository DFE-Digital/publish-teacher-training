require "rails_helper"

RSpec.describe API::Public::V1::Providers::CoursesController do
  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }

  describe "#index" do
    context "when there are no courses" do
      before do
        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
        }
      end

      it "returns empty array of data" do
        expect(JSON.parse(response.body)["data"]).to eql([])
      end
    end

    context "when there are courses" do
      before do
        create(:course, provider: provider)
        create(:course, provider: provider)

        get :index, params: {
          recruitment_cycle_year: "2020",
          provider_code: provider.provider_code,
        }
      end

      it "returns correct number of courses" do
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

        get :index, params: {
          recruitment_cycle_year: "2020",
          provider_code: "ABC",
          page: {
            page: 2,
            per_page: 5,
          },
        }
      end

      it "can pagingate to page 2" do
        expect(JSON.parse(response.body)["data"].size).to eql(2)
      end
    end

    describe "include" do
      let!(:course) { create(:course, :with_accrediting_provider, provider: provider) }

      context "when includes specified" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            include: "provider,accredited_body",
          }
        end

        it "returns the provider and accrediting body connected to the course" do
          expect(JSON.parse(response.body)["data"][0]["relationships"].keys).to include("provider")
          expect(JSON.parse(response.body)["data"][0]["relationships"].keys).to include("accredited_body")
          expect(JSON.parse(response.body)["included"][0]["id"]).to eql(course.accrediting_provider.id.to_s)
          expect(JSON.parse(response.body)["included"][0]["type"]).to eql("providers")
          expect(JSON.parse(response.body)["included"][1]["id"]).to eql(provider.id.to_s)
          expect(JSON.parse(response.body)["included"][1]["type"]).to eql("providers")
        end
      end

      context "when includes are not part of the serailizer" do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            include: "subjects",
          }
        end

        it "doesn't include subjects" do
          expect(JSON.parse(response.body)["data"][0]["relationships"].keys).to_not include("subjects")
        end
      end
    end
  end

  describe "#show" do
    context "when course exists" do
      let!(:course) { create(:course, provider: provider) }

      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
        }
      end

      it "returns the course" do
        expect(response).to be_successful
        expect(JSON.parse(response.body)["data"]["id"]).to eql(course.id.to_s)
      end
    end

    context "with include" do
      let!(:course) do
        create(:course, :with_accrediting_provider, provider: provider)
      end

      let(:accredited_body) { course.accrediting_provider }

      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
          include: "provider,accredited_body,recruitment_cycle",
        }
      end

      it "returns the course with includes" do
        expect(response).to be_successful

        expect(JSON.parse(response.body)["data"]["id"]).to eql(course.id.to_s)

        expect(JSON.parse(response.body)["included"][0]["id"]).to eql(accredited_body.id.to_s)
        expect(JSON.parse(response.body)["included"][0]["type"]).to eql("providers")

        expect(JSON.parse(response.body)["included"][1]["id"]).to eql(provider.id.to_s)
        expect(JSON.parse(response.body)["included"][1]["type"]).to eql("providers")
      end
    end

    context "when course does not exist" do
      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: "ABCD",
        }
      end

      it "returns 404" do
        expect(response.status).to eql(404)
      end
    end

    context "when provider does not exist" do
      before do
        get :show, params: {
          recruitment_cycle_year: "2020",
          provider_code: "ABC",
          code: "ABCD",
        }
      end

      it "returns 404" do
        expect(response.status).to eql(404)
      end
    end
  end
end

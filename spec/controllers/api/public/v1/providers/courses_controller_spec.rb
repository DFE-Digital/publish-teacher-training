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
  end
end

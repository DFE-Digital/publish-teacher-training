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
        provider.courses << build_list(:course, 2, provider: provider)
      end

      context "default response" do
        before do
          get :index, params: {
            recruitment_cycle_year: "2020",
          }
        end

        it "returns correct number of courses" do
          expect(json_response["data"].size).to eql(2)
        end
      end

      context "with pagination" do
        before do
          provider.courses << build_list(:course, 5, provider: provider)

          get :index, params: {
            recruitment_cycle_year: "2020",
            page: {
              page: 2,
              per_page: 5,
            },
          }
        end

        it "can pagingate to page 2" do
          expect(json_response["data"].size).to eql(2)
        end
      end

      context "with includes" do
        before do
          get :index, params: {
            recruitment_cycle_year: "2020",
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
          allow(CourseSearchService).to receive(:call).and_return([])

          get :index, params: {
            recruitment_cycle_year: "2020",
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
        before do
          provider.courses << build(:course, provider: provider)

          allow(CourseSearchService).to receive(:call).and_return([])

          get :index, params: {
            recruitment_cycle_year: "2020",
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
    end
  end
end

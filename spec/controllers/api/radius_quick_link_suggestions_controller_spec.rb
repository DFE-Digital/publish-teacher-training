# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::RadiusQuickLinkSuggestionsController do
  describe "#index" do
    let(:nearby_course) { double("Course", minimum_distance_to_search_location: 10) }
    let(:midrange_course) { double("Course", minimum_distance_to_search_location: 50) }
    let(:distant_course) { double("Course", minimum_distance_to_search_location: 150) }

    let(:search_params) do
      {
        location: "London",
        subject: "maths",
      }
    end

    context "with invalid params" do
      before do
        get :index, params: {}
      end

      it "responds with 400 status" do
        expect(response).to have_http_status(:bad_request)
        expect(json_response["errors"]).to eq(
          [{
            "status" => 400,
            "title" => "BAD REQUEST",
            "detail" => "Search parameters missing",
          }],
        )
      end
    end

    context "with valid params" do
      let(:query_result) { double("QueryResult") }

      before do
        allow(query_result).to receive(:limit).with(101).and_return([nearby_course, midrange_course, distant_course])

        allow(Courses::Query).to receive(:call)
          .with(params: hash_including(search_params.merge(radius: 200)))
          .and_return(query_result)

        get :index, params: search_params
      end

      it "responds with 200 OK and a list of quick link suggestions" do
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response).to all(include("text", "url"))
      end
    end

    context "when a bucket has over 100 results" do
      let(:over_limit_courses) { Array.new(150) { double("Course", minimum_distance_to_search_location: 10) } }
      let(:query_result) { double("QueryResult") }

      before do
        allow(query_result).to receive(:limit).with(101).and_return(over_limit_courses)

        allow(Courses::Query).to receive(:call)
          .with(params: hash_including(search_params.merge(radius: 200)))
          .and_return(query_result)

        get :index, params: search_params
      end

      it "responds with a single suggestion with 100+ courses text" do
        expect(response).to have_http_status(:ok)
        expect(json_response.length).to eq(1)
        expect(json_response.first["text"]).to match("more than 100 courses")
      end
    end
  end
end

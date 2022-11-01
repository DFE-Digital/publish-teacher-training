require "rails_helper"

module Find
  describe "/find/location-suggestions" do
    include StubbedRequests::LocationSuggestions

    context "when provider suggestion is blank" do
      it "returns bad request (400)" do
        get "/find/location-suggestions"

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq("error" => "Bad request")
      end
    end

    context "when location suggestion query is valid" do
      it "returns success (200)" do
        query = "london"
        location_suggestions = stub_location_suggestions(query:)
        get "/find/location-suggestions?query=#{query}"

        expect(location_suggestions).to have_been_requested
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

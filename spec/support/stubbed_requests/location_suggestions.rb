module StubbedRequests
  module LocationSuggestions
    def stub_location_suggestions(query:)
      stub_request(
        :get,
        "#{Settings.google.places_api_host}/maps/api/place/autocomplete/json?components=country:uk&input=#{query}&key=replace_me&language=en&types=geocode"
      ).to_return(body: File.new("spec/fixtures/api_responses/location-suggestions.json"), headers: { "Content-Type": "application/json" })
    end
  end
end

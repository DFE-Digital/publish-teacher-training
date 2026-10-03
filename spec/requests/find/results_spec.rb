# frozen_string_literal: true

require "rails_helper"

describe "/results" do
  context "when page parameter is invalid" do
    before do
      get "/results", params: { page: "some-site-.co.uk" }
    end

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "tracking the start date filter" do
    let(:event) { instance_double(Find::Analytics::SearchResultsEvent, send_event: nil) }

    before do
      allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
      allow(Find::Analytics::SearchResultsEvent).to receive(:new).and_return(event)
    end

    it "sends the selected start date options" do
      get "/results", params: { start_date: %w[september next_jul] }

      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(search_params: hash_including(start_date: %w[september next_jul])),
      )
    end

    it "sends the options that replaced one the filter used to offer" do
      get "/results", params: { start_date: %w[jan_to_aug] }

      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(search_params: hash_including(start_date: %w[jan_to_mar apr_to_jun jul_to_aug])),
      )
    end
  end
end

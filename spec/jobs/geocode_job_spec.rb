# frozen_string_literal: true

require "rails_helper"

RSpec.describe GeocodeJob, type: :job do
  let!(:site) do
    create(:site,
           skip_geocoding: true,
           address1: "Long Lane",
           address2: "Holbury",
           town: "Southampton",
           address4: nil,
           postcode: "SO45 2PA")
  end

  it_behaves_like "a job routed to Solid Queue", queue: "geocoding" do
    let(:solid_queue_job_args) { ["Site", site.id] }
  end

  it "calls the GeocoderService" do
    expect(GeocoderService).to receive(:geocode).with(obj: site)

    described_class.perform_now("Site", site.id)
  end
end

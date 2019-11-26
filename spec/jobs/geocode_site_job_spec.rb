require "rails_helper"
describe GeocodeSiteJob, type: :job do
  let(:site) {
    create(:site,
           address1: "Long Lane",
           address2: "Holbury",
           address3: "Southampton",
           address4: nil,
           postcode: "SO45 2PA")
  }

  it "queues the expected job" do
    described_class.perform_later(site.id)

    expect(GeocodeSiteJob)
      .to have_been_enqueued.on_queue("geocoding")
  end

  it "searches and stores geocoding" do
    results = [
      OpenStruct.new(latitude: 50.345676, longitude: -1.345676)
    ]
    allow(Geocoder).to receive(:search).and_return(results)
    expect(Geocoder).to receive(:search).with(site.full_address)

    described_class.perform_now(site.id)

    updated_site = Site.find(site.id)

    expect(updated_site.latitude).to eq(50.345676)
    expect(updated_site.longitude).to eq(-1.345676)
  end
end

require "rails_helper"
describe GeocodeJob, type: :job do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  let(:site) {
    build(:site,
          address1: "Long Lane",
          address2: "Holbury",
          address3: "Southampton",
          address4: nil,
          postcode: "SO45 2PA")
  }

  subject(:job) { described_class.perform_later("Site", site.id) }

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is put into the geocoding queue" do
    expect(described_class.new.queue_name).to eq("geocoding")
  end

  it "executes perform" do
    results = [
      OpenStruct.new(latitude: 50.345676, longitude: -1.345676),
    ]

    allow(Geocoder).to receive(:search).and_return(results)
    expect(Geocoder).to receive(:search).with(site.full_address)

    site.save!
    perform_enqueued_jobs { job }

    updated_site = Site.find(site.id)

    expect(updated_site.latitude).to eq(50.345676)
    expect(updated_site.longitude).to eq(-1.345676)
  end
end

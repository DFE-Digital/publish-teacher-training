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

  it "uses Solid Queue explicitly for this pilot job" do
    expect(described_class.queue_adapter).to be_a(ActiveJob::QueueAdapters::SolidQueueAdapter)
  end

  it "can be enqueued onto Solid Queue on the geocoding queue" do
    expect {
      described_class.perform_later("Site", site.id)
    }.to change { SolidQueue::Job.where(class_name: "GeocodeJob").count }.by(1)

    job = SolidQueue::Job.where(class_name: "GeocodeJob").order(:id).last
    expect(job.queue_name).to eq("geocoding")
  end

  it "is put into the geocoding queue" do
    expect(described_class.new.queue_name).to eq("geocoding")
  end

  it "calls the GeocoderService" do
    expect(GeocoderService).to receive(:geocode).with(obj: site)

    described_class.perform_now("Site", site.id)
  end
end

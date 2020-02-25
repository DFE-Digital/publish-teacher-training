require "rails_helper"
describe GeocodeJob, type: :job do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  let(:site) do
    build(:site,
          address1: "Long Lane",
          address2: "Holbury",
          address3: "Southampton",
          address4: nil,
          postcode: "SO45 2PA")
  end

  subject(:job) { described_class.perform_later("Site", site.id) }

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is put into the geocoding queue" do
    expect(described_class.new.queue_name).to eq("geocoding")
  end

  context "executing the job" do
    it "calls the GeocoderService" do
      expect(GeocoderService).to receive(:geocode).with(obj: site)

      site.save!

      perform_enqueued_jobs { job }
    end
  end
end

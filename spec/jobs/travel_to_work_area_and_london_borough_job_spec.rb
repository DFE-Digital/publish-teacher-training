require "rails_helper"
describe TravelToWorkAreaAndLondonBoroughJob, type: :job do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  let(:site) do
    build(:site,
          address1: "28 Great Smith Street",
          address2: "London",
          address3: "",
          address4: "UK",
          postcode: "SW1P 3BT",
          latitude: 51.498160,
          longitude: -0.129900)
  end

  subject(:job) { described_class.perform_later("Site", site.id) }

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is put into the add_travel_to_work_area_and_london_borough queue" do
    expect(described_class.new.queue_name).to eq("add_travel_to_work_area_and_london_borough")
  end

  context "executing the job" do
    it "calls the GeocoderService" do
      expect(TravelToWorkAreaAndLondonBoroughService).to receive(:add_travel_to_work_area_and_london_borough).with(site: site)

      site.save!

      perform_enqueued_jobs { job }
    end
  end
end

require "rails_helper"

RSpec.describe Geolocation::QueryCache do
  it "clears the right keys" do
    Rails.cache.write("geolocation:query:south-london-uk", "value")

    expect(Rails.cache.read("geolocation:query:south-london-uk")).to eq("value")

    described_class.clear!

    expect(Rails.cache.read("geolocation:query:south-london-uk")).to be_nil
  end
end

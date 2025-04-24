require "rails_helper"

RSpec.describe Geolocation::ClearCache do
  it "clears the right keys" do
    redis = Redis.new
    redis.set("geolocation:query:south-london-uk", "value")

    expect(redis.get("geolocation:query:south-london-uk")).to eq("value")

    described_class.suggestions

    expect(redis.get("geolocation:query:south-london-uk")).to be_nil
  end
end

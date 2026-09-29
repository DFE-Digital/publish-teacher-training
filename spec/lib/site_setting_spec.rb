# frozen_string_literal: true

require "rails_helper"

describe SiteSetting do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ENABLE_SWITCHER").and_return("1")
  end

  describe ".cycle_schedule" do
    it "only reads the cycle schedule from Redis once per request" do
      RedisClient.current.set("cycle_schedule", "apply_open")
      expect(RedisClient.current).to receive(:get).with("cycle_schedule").once.and_call_original

      2.times { expect(described_class.cycle_schedule).to eq(:apply_open) }
    end

    it "invalidates the request cache when the cycle schedule changes" do
      RedisClient.current.set("cycle_schedule", "apply_open")

      expect(described_class.cycle_schedule).to eq(:apply_open)

      described_class.set(name: "cycle_schedule", value: "find_closed")

      expect(described_class.cycle_schedule).to eq(:find_closed)
    end
  end
end

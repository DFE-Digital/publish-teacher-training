# frozen_string_literal: true

require "rails_helper"

describe SiteSetting do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ENABLE_SWITCHER").and_return("1")
  end

  describe ".cycle_schedule" do
    it "defaults to the real schedule" do
      expect(described_class.cycle_schedule).to eq(:real)
    end

    it "reads every setting in one query per request" do
      described_class.create!(name: "cycle_schedule", value: "apply_open")
      described_class.create!(name: "deadline_banner", value: "true")
      Current.reset

      expect(described_class).to receive(:pluck).once.and_call_original

      2.times do
        expect(described_class.cycle_schedule).to eq(:apply_open)
        expect(described_class.deadline_banner?).to be(true)
      end
    end

    it "does not read Redis" do
      expect(RedisClient.current).not_to receive(:get)

      described_class.cycle_schedule
    end

    it "invalidates the request cache when the cycle schedule changes" do
      described_class.create!(name: "cycle_schedule", value: "apply_open")

      expect(described_class.cycle_schedule).to eq(:apply_open)

      described_class.set(name: "cycle_schedule", value: "find_closed")

      expect(described_class.cycle_schedule).to eq(:find_closed)
    end
  end

  describe ".set" do
    it "stores the setting and mirrors it to Redis" do
      described_class.set(name: "cycle_schedule", value: :apply_open)

      expect(described_class.find_by(name: "cycle_schedule").value).to eq("apply_open")
      expect(RedisClient.current.get("cycle_schedule")).to eq("apply_open")
    end

    it "updates an existing setting" do
      described_class.set(name: "deadline_banner", value: "true")
      described_class.set(name: "deadline_banner", value: "false")

      expect(described_class.where(name: "deadline_banner").pluck(:value)).to eq(%w[false])
      expect(described_class.deadline_banner?).to be(false)
    end

    it "rejects unknown settings" do
      expect { described_class.set(name: "unknown", value: "x") }.to raise_error(ActiveRecord::RecordInvalid)
      expect(RedisClient.current.get("unknown")).to be_nil
    end

    it "keeps the database unchanged if Redis cannot be written" do
      allow(RedisClient.current).to receive(:set).and_raise(Redis::CannotConnectError)

      expect { described_class.set(name: "cycle_schedule", value: "apply_open") }.to raise_error(Redis::CannotConnectError)
      expect(described_class.exists?(name: "cycle_schedule")).to be(false)
    end
  end
end

require "rails_helper"

RSpec.describe ErrorReporting::RateLimiter do
  it "stays silent below the threshold and fires from the threshold onward" do
    results = 15.times.map { described_class.report?(key: "x", threshold: 10) }

    expect(results).to eq(([false] * 9) + ([true] * 6))
  end

  it "tracks keys independently" do
    9.times { described_class.report?(key: "a", threshold: 10) }

    expect(described_class.report?(key: "b", threshold: 10)).to be false
    expect(described_class.report?(key: "a", threshold: 10)).to be true
  end

  it "ages out counts from outside the window" do
    Timecop.freeze do
      10.times { described_class.report?(key: "x", threshold: 10, window: 1.hour) }
      expect(described_class.report?(key: "x", threshold: 10, window: 1.hour)).to be true

      Timecop.travel(1.hour + 1.second) do
        expect(described_class.report?(key: "x", threshold: 10, window: 1.hour)).to be false
      end
    end
  end

  it "fails open if the cache raises" do
    allow(Rails.cache).to receive(:increment).and_raise(StandardError)

    expect(described_class.report?(key: "x", threshold: 10)).to be true
  end

  it "fails open if the cache returns nil" do
    allow(Rails.cache).to receive(:increment).and_return(nil)

    expect(described_class.report?(key: "x", threshold: 10)).to be true
  end

  it "reads previous buckets as raw values for Redis compatibility" do
    allow(Rails.cache).to receive_messages(increment: 1, read_multi: {})

    described_class.report?(key: "x", threshold: 10, window: 2.minutes)

    expect(Rails.cache).to have_received(:read_multi).with(a_string_matching(/error_reporting:x:\d+/), raw: true)
  end
end

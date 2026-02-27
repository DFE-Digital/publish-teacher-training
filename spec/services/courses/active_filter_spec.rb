require "rails_helper"

RSpec.describe Courses::ActiveFilter do
  describe "#formatted_value" do
    it "returns the raw value for subject filters" do
      active_filter = described_class.new(
        id: :subjects,
        raw_value: "00",
        value: "Primary",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to eq("Primary")
    end

    it "returns the raw value for provider filters" do
      active_filter = described_class.new(
        id: :provider_code,
        raw_value: "ABC",
        value: "Example provider",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to eq("Example provider")
    end

    it "returns translated text for funding filters" do
      active_filter = described_class.new(
        id: :funding,
        raw_value: "fee",
        value: "fee",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to eq("Fee-paying courses")
    end

    it "returns translated text for study type filters" do
      active_filter = described_class.new(
        id: :study_types,
        raw_value: "full_time",
        value: "full_time",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to eq("Full time")
    end

    it "returns translated text for qualification filters" do
      active_filter = described_class.new(
        id: :qualifications,
        raw_value: "qts",
        value: "qts",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to eq("Qualification: QTS only")
    end

    it "returns translated text for minimum degree filters" do
      active_filter = described_class.new(
        id: :minimum_degree_required,
        raw_value: "two_one",
        value: "two_one",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to eq("Degree grade: 2:1 or first")
    end

    it "returns nil when translation is missing for non-special ids" do
      allow(I18n).to receive(:t).and_raise(StandardError)

      active_filter = described_class.new(
        id: :unknown_filter,
        raw_value: "unknown",
        value: "unknown",
        remove_params: {},
      )

      formatted_value = active_filter.formatted_value

      expect(formatted_value).to be_nil
    end
  end

  describe "attributes" do
    it "exposes id, raw_value, value and remove_params" do
      active_filter = described_class.new(
        id: :funding,
        raw_value: "fee",
        value: "Fee-paying courses",
        remove_params: { funding: nil },
      )

      expect(active_filter.id).to eq(:funding)
      expect(active_filter.raw_value).to eq("fee")
      expect(active_filter.value).to eq("Fee-paying courses")
      expect(active_filter.remove_params).to eq({ funding: nil })
    end
  end
end

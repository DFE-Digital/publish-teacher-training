# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::SearchParamDefaults do
  describe "#default_value?" do
    it "returns true for applications_open=true" do
      defaults = described_class.new(applications_open: "true")
      expect(defaults.default_value?("applications_open", "true")).to be true
    end

    it "returns false for applications_open=false" do
      defaults = described_class.new(applications_open: "false")
      expect(defaults.default_value?("applications_open", "false")).to be false
    end

    it "returns true for minimum_degree_required=show_all_courses" do
      defaults = described_class.new(minimum_degree_required: "show_all_courses")
      expect(defaults.default_value?("minimum_degree_required", "show_all_courses")).to be true
    end

    it "returns false for minimum_degree_required=two_one" do
      defaults = described_class.new(minimum_degree_required: "two_one")
      expect(defaults.default_value?("minimum_degree_required", "two_one")).to be false
    end

    it "returns true for level=all" do
      defaults = described_class.new(level: "all")
      expect(defaults.default_value?("level", "all")).to be true
    end

    it "returns false for level=secondary" do
      defaults = described_class.new(level: "secondary")
      expect(defaults.default_value?("level", "secondary")).to be false
    end

    context "order default depends on location" do
      it "returns true for order=course_name_ascending without location" do
        defaults = described_class.new(order: "course_name_ascending")
        expect(defaults.default_value?("order", "course_name_ascending")).to be true
      end

      it "returns false for order=distance without location" do
        defaults = described_class.new(order: "distance")
        expect(defaults.default_value?("order", "distance")).to be false
      end

      it "returns true for order=distance with longitude" do
        defaults = described_class.new(order: "distance", longitude: "-1.5")
        expect(defaults.default_value?("order", "distance")).to be true
      end

      it "returns false for order=course_name_ascending with longitude" do
        defaults = described_class.new(order: "course_name_ascending", longitude: "-1.5")
        expect(defaults.default_value?("order", "course_name_ascending")).to be false
      end

      it "returns true for order=distance with short_address" do
        defaults = described_class.new(order: "distance", short_address: "Manchester")
        expect(defaults.default_value?("order", "distance")).to be true
      end
    end

    it "returns false for unknown keys" do
      defaults = described_class.new(funding: "salary")
      expect(defaults.default_value?("funding", "salary")).to be false
    end

    it "works with symbol keys" do
      defaults = described_class.new(level: "all")
      expect(defaults.default_value?(:level, "all")).to be true
    end
  end

  describe "#non_default?" do
    it "returns true when value differs from default" do
      defaults = described_class.new(minimum_degree_required: "two_one")
      expect(defaults.non_default?("minimum_degree_required", "two_one")).to be true
    end

    it "returns false when value matches default" do
      defaults = described_class.new(minimum_degree_required: "show_all_courses")
      expect(defaults.non_default?("minimum_degree_required", "show_all_courses")).to be false
    end
  end
end

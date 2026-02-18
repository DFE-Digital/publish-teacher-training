# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::ActiveFilters::TagExtractor do
  describe "#call" do
    subject(:tags) { described_class.new(attrs, subject_names:).call }

    let(:attrs) { {} }
    let(:subject_names) { [] }

    context "with no attributes" do
      it "returns an empty array" do
        expect(tags).to eq([])
      end
    end

    context "with provider_name" do
      let(:attrs) { { "provider_name" => "University of Bristol" } }

      it "includes the provider name directly" do
        expect(tags).to eq(["University of Bristol"])
      end
    end

    context "with subject names" do
      let(:subject_names) { %w[Mathematics Physics] }

      it "includes the subject names" do
        expect(tags).to eq(%w[Mathematics Physics])
      end
    end

    context "with location" do
      let(:attrs) { { "location" => "London" } }

      it "includes the location name" do
        expect(tags).to eq(%w[London])
      end
    end

    context "with location and radius" do
      let(:attrs) { { "location" => "London", "radius" => "20" } }

      it "includes the location with radius" do
        expect(tags).to eq(["Within 20 miles of London"])
      end
    end

    context "with formatted_address fallback" do
      let(:attrs) { { "formatted_address" => "Bristol, UK" } }

      it "uses formatted_address when location is absent" do
        expect(tags).to eq(["Bristol, UK"])
      end
    end

    context "with can_sponsor_visa" do
      let(:attrs) { { "can_sponsor_visa" => true } }

      it "includes the visa sponsorship tag" do
        expect(tags).to eq(["Visa sponsorship"])
      end
    end

    context "with funding" do
      let(:attrs) { { "funding" => %w[salary fee] } }

      it "translates each funding value" do
        expect(tags).to eq(%w[Salary Fee])
      end
    end

    context "with study_types" do
      let(:attrs) { { "study_types" => %w[full_time part_time] } }

      it "translates each study type" do
        expect(tags).to eq(["Full time", "Part time"])
      end
    end

    context "with qualifications" do
      let(:attrs) { { "qualifications" => %w[qts qts_with_pgce_or_pgde] } }

      it "translates each qualification" do
        expect(tags).to eq(["QTS only", "QTS with PGCE or PGDE"])
      end
    end

    context "with minimum_degree_required" do
      let(:attrs) { { "minimum_degree_required" => "two_two" } }

      it "translates the degree requirement" do
        expect(tags).to eq(["Degree: 2:2"])
      end
    end

    context "with minimum_degree_required set to show_all_courses" do
      let(:attrs) { { "minimum_degree_required" => "show_all_courses" } }

      it "skips the default value" do
        expect(tags).to be_empty
      end
    end

    context "with start_date" do
      let(:attrs) { { "start_date" => %w[september jan_to_aug] } }

      it "translates each start date" do
        expect(tags).to eq(["September", "January to August"])
      end
    end

    context "with send_courses" do
      let(:attrs) { { "send_courses" => true } }

      it "includes the SEND courses tag" do
        expect(tags).to eq(["SEND courses"])
      end
    end

    context "with level" do
      let(:attrs) { { "level" => "further_education" } }

      it "humanizes the level" do
        expect(tags).to eq(["Further education"])
      end
    end

    context "with level set to all" do
      let(:attrs) { { "level" => "all" } }

      it "skips the default level" do
        expect(tags).to be_empty
      end
    end

    context "with all attributes" do
      let(:attrs) do
        {
          "provider_name" => "University of Bristol",
          "location" => "London",
          "radius" => "20",
          "can_sponsor_visa" => true,
          "funding" => %w[salary],
          "study_types" => %w[full_time],
          "qualifications" => %w[qts],
          "minimum_degree_required" => "two_two",
          "start_date" => %w[september],
          "send_courses" => true,
          "level" => "further_education",
        }
      end
      let(:subject_names) { %w[Mathematics] }

      it "returns tags in the correct order" do
        expect(tags).to eq([
          "University of Bristol",
          "Mathematics",
          "Within 20 miles of London",
          "Visa sponsorship",
          "Salary",
          "Full time",
          "QTS only",
          "Degree: 2:2",
          "September",
          "SEND courses",
          "Further education",
        ])
      end
    end

    context "with invalid array values" do
      let(:attrs) { { "funding" => %w[invalid_option] } }

      it "skips invalid values" do
        expect(tags).to be_empty
      end
    end

    context "with symbol keys" do
      let(:attrs) { { can_sponsor_visa: true } }

      it "handles symbol keys by converting them" do
        expect(tags).to eq(["Visa sponsorship"])
      end
    end
  end
end

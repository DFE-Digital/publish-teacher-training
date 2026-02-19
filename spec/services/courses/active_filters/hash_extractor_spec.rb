# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::ActiveFilters::HashExtractor do
  describe "#call" do
    subject(:filters) { described_class.new(attrs, subject_names:, provider_name:).call }

    let(:attrs) { {} }
    let(:subject_names) { [] }
    let(:provider_name) { nil }

    def formatted_values
      filters.map(&:formatted_value)
    end

    context "with no attributes" do
      it "returns an empty array" do
        expect(filters).to eq([])
      end
    end

    context "with provider_name" do
      let(:provider_name) { "University of Bristol" }

      it "includes the provider name as a passthrough" do
        expect(formatted_values).to eq(["University of Bristol"])
      end
    end

    context "with subject names" do
      let(:subject_names) { %w[Mathematics Physics] }

      it "includes the subject names as passthroughs" do
        expect(formatted_values).to eq(%w[Mathematics Physics])
      end
    end

    context "with location and radius" do
      let(:attrs) { { "location" => "Manchester", "radius" => "15" } }

      it "combines into a single location filter" do
        expect(formatted_values).to eq(["Within 15 miles of Manchester"])
      end
    end

    context "with formatted_address fallback" do
      let(:attrs) { { "formatted_address" => "Bristol, UK", "radius" => "10" } }

      it "uses formatted_address when location is absent" do
        expect(formatted_values).to eq(["Within 10 miles of Bristol, UK"])
      end
    end

    context "with can_sponsor_visa" do
      let(:attrs) { { "can_sponsor_visa" => "true" } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Courses with visa sponsorship"])
      end
    end

    context "with funding" do
      let(:attrs) { { "funding" => %w[salary] } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Courses with a salary"])
      end
    end

    context "with study_types" do
      let(:attrs) { { "study_types" => %w[full_time part_time] } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(%w[Full-time Part-time])
      end
    end

    context "with qualifications" do
      let(:attrs) { { "qualifications" => %w[qts_with_pgce_or_pgde] } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Qualification: QTS with PGCE or PGDE"])
      end
    end

    context "with minimum_degree_required" do
      let(:attrs) { { "minimum_degree_required" => "two_one" } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Degree grade: 2:1 or first"])
      end
    end

    context "with minimum_degree_required set to show_all_courses" do
      let(:attrs) { { "minimum_degree_required" => "show_all_courses" } }

      it "skips the default value" do
        expect(filters).to be_empty
      end
    end

    context "with start_date" do
      let(:attrs) { { "start_date" => %w[september] } }

      it "translates via active_filters.yml with cycle year" do
        year = Find::CycleTimetable.current_year
        expect(formatted_values).to eq(["Start date: September #{year} only"])
      end
    end

    context "with send_courses" do
      let(:attrs) { { "send_courses" => "true" } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Courses with a SEND specialism"])
      end
    end

    context "with interview_location" do
      let(:attrs) { { "interview_location" => "online" } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Courses with online interviews"])
      end
    end

    context "with level set to all (default)" do
      let(:attrs) { { "level" => "all" } }

      it "skips the default level" do
        expect(filters).to be_empty
      end
    end

    context "with level set to further_education" do
      let(:attrs) { { "level" => "further_education" } }

      it "translates via active_filters.yml" do
        expect(formatted_values).to eq(["Further education"])
      end
    end

    context "with skipped keys" do
      let(:attrs) { { "order" => "course_name_ascending", "applications_open" => "true", "radius" => "15", "subject_code" => "C1" } }

      it "ignores all skipped keys" do
        expect(filters).to be_empty
      end
    end

    context "with many filters" do
      let(:provider_name) { "University of Bristol" }
      let(:subject_names) { %w[Biology] }
      let(:attrs) do
        {
          "location" => "Manchester",
          "radius" => "15",
          "can_sponsor_visa" => "true",
          "funding" => %w[salary],
          "study_types" => %w[full_time],
          "qualifications" => %w[qts_with_pgce_or_pgde],
          "minimum_degree_required" => "two_one",
          "start_date" => %w[september],
          "send_courses" => "true",
          "level" => "secondary",
        }
      end

      it "returns filters in the correct order" do
        year = Find::CycleTimetable.current_year
        expect(formatted_values).to eq([
          "University of Bristol",
          "Biology",
          "Within 15 miles of Manchester",
          "Courses with a SEND specialism",
          "Courses with a salary",
          "Full-time",
          "Qualification: QTS with PGCE or PGDE",
          "Degree grade: 2:1 or first",
          "Courses with visa sponsorship",
          "Start date: September #{year} only",
        ])
      end
    end
  end
end

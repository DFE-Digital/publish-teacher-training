# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::Courses::SearchTitleComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(subjects:, location_name:, radius:, search_attributes:))
  end

  let(:subjects) { [] }
  let(:location_name) { nil }
  let(:radius) { nil }
  let(:search_attributes) { {} }

  context "with 1 subject and no location" do
    let(:subjects) { %w[Mathematics] }

    it { expect(rendered.text).to eq("Mathematics courses in England") }
  end

  context "with 2 subjects and no location" do
    let(:subjects) { %w[Mathematics Physics] }

    it { expect(rendered.text).to eq("Mathematics and Physics courses in England") }
  end

  context "with 3+ subjects and no location" do
    let(:subjects) { %w[Mathematics Physics Chemistry] }

    it { expect(rendered.text).to eq("3 subjects in England") }
  end

  context "with no subjects and a location" do
    let(:location_name) { "Manchester" }
    let(:radius) { 10 }

    it { expect(rendered.text).to eq("Courses within 10 miles of Manchester") }
  end

  context "with 1 subject and a location" do
    let(:subjects) { %w[Mathematics] }
    let(:location_name) { "Manchester" }
    let(:radius) { 15 }

    it { expect(rendered.text).to eq("Mathematics courses within 15 miles of Manchester") }
  end

  context "with 2 subjects and a location" do
    let(:subjects) { %w[Mathematics Physics] }
    let(:location_name) { "Manchester" }
    let(:radius) { 15 }

    it { expect(rendered.text).to eq("Mathematics and Physics courses within 15 miles of Manchester") }
  end

  context "with 3+ subjects and a location" do
    let(:subjects) { %w[Mathematics Physics Chemistry] }
    let(:location_name) { "Manchester" }
    let(:radius) { 15 }

    it { expect(rendered.text).to eq("Courses within 15 miles of Manchester") }
  end

  context "with a provider name only" do
    let(:search_attributes) { { "provider_name" => "Manchester Metropolitan University (M40)" } }

    it { expect(rendered.text).to eq("Courses across England") }
  end

  context "with a provider name and default keys" do
    let(:search_attributes) { { "provider_name" => "Manchester Metropolitan University (M40)", "applications_open" => "true", "order" => "course_name_ascending" } }

    it { expect(rendered.text).to eq("Courses across England") }
  end

  context "with a provider name and non-default filter" do
    let(:search_attributes) { { "provider_name" => "Manchester Metropolitan University (M40)", "send_courses" => "true" } }

    it { expect(rendered.text).to eq("Courses across England (1 filter applied)") }
  end

  context "with no subject/location but visa sponsorship" do
    let(:search_attributes) { { "can_sponsor_visa" => "true" } }

    it { expect(rendered.text).to eq("Courses with visa sponsorship") }
  end

  context "with no subject/location/visa but apprenticeship funding" do
    let(:search_attributes) { { "funding" => %w[apprenticeship] } }

    it { expect(rendered.text).to eq("Apprenticeship courses in England") }
  end

  context "with no subject/location/visa but salary funding" do
    let(:search_attributes) { { "funding" => %w[salary] } }

    it { expect(rendered.text).to eq("Salaried courses in England") }
  end

  context "with 1 filter in fallback" do
    let(:search_attributes) { { "level" => "primary" } }

    it { expect(rendered.text).to eq("Courses across England (1 filter applied)") }
  end

  context "with 2 filters in fallback" do
    let(:search_attributes) { { "level" => "primary", "send_courses" => "true" } }

    it { expect(rendered.text).to eq("Courses across England (2 filters applied)") }
  end

  context "with provider params excluded from filter count" do
    let(:search_attributes) { { "provider_name" => "Test Provider (TP1)", "provider_code" => "TP1", "send_courses" => "true" } }

    it "counts only non-default keys as filters" do
      expect(rendered.text).to eq("Courses across England (1 filter applied)")
    end
  end

  context "with provider_code and provider_name as only non-default keys in fallback" do
    let(:search_attributes) { { "provider_code" => "TP1", "level" => "secondary" } }

    it "excludes provider_code from filter count and uses singular filter" do
      expect(rendered.text).to eq("Courses across England (1 filter applied)")
    end
  end

  context "with only default filter keys" do
    let(:search_attributes) { { "applications_open" => "true", "minimum_degree_required" => "show_all_courses", "order" => "course_name_ascending" } }

    it { expect(rendered.text).to eq("Courses across England") }
  end

  context "with no filters at all" do
    it { expect(rendered.text).to eq("Courses across England") }
  end
end

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
    let(:subjects) { ["Mathematics"] }

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
    let(:subjects) { ["Mathematics"] }
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

  context "with no subject/location but visa sponsorship" do
    let(:search_attributes) { { "can_sponsor_visa" => "true" } }

    it { expect(rendered.text).to eq("Courses with visa sponsorship") }
  end

  context "with no subject/location/visa but apprenticeship funding" do
    let(:search_attributes) { { "funding" => ["apprenticeship"] } }

    it { expect(rendered.text).to eq("Apprenticeship courses in England") }
  end

  context "with no subject/location/visa but salary funding" do
    let(:search_attributes) { { "funding" => ["salary"] } }

    it { expect(rendered.text).to eq("Salaried courses in England") }
  end

  context "with filters but no subject/location/visa/apprenticeship/salary" do
    let(:search_attributes) { { "level" => "primary", "send_courses" => "true" } }

    it { expect(rendered.text).to eq("Courses across England (2 filters applied)") }
  end

  context "with no filters at all" do
    it { expect(rendered.text).to eq("Courses across England") }
  end
end
